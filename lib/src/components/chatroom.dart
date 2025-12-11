import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Chatroom extends StatefulWidget {
  final String roomId;
  final Map friend;

  const Chatroom({
    super.key,
    required this.roomId,
    required this.friend,
  });

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  final supabase = Supabase.instance.client;

  final List<Map<String, dynamic>> messages = [];
  final ScrollController scroll = ScrollController();
  final TextEditingController controller = TextEditingController();

  RealtimeChannel? channel;

  @override
  void initState() {
    super.initState();
    loadMessages();
    subscribeRealtime();
  }

  @override
  void dispose() {
    channel?.unsubscribe();
    controller.dispose();
    scroll.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // ✅ Load previous messages (history)
  // ----------------------------------------------------------
  Future<void> loadMessages() async {
    final res = await supabase
        .from("messages")
        .select()
        .eq("room_id", widget.roomId)
        .order("created_at", ascending: true);

    setState(() {
      messages.clear();
      messages.addAll(List<Map<String, dynamic>>.from(res));
    });

    // scroll to bottom after load
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  // ----------------------------------------------------------
  // ✅ Realtime subscription (modern API)
  // ----------------------------------------------------------
  void subscribeRealtime() {
    channel = supabase.channel("room-${widget.roomId}");

    channel!
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: "public",
      table: "messages",
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: "room_id",
        value: widget.roomId,
      ),
      callback: (payload) {
        final record = payload.newRecord;

        setState(() {
          messages.add(record);
        });

        // auto-scroll when a new message arrives
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom();
        });
            },
    )
        .subscribe();
  }

  // ----------------------------------------------------------
  // ✅ Send message
  // ----------------------------------------------------------
  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final uid = supabase.auth.currentUser!.id;

    await supabase.from("messages").insert({
      "room_id": widget.roomId,
      "sender_id": uid,
      "body": text,
    });

    controller.clear();
  }

  // ----------------------------------------------------------
  // ✅ Scroll helper
  // ----------------------------------------------------------
  void scrollToBottom() {
    if (scroll.hasClients) {
      scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ----------------------------------------------------------
  // ✅ UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final myId = supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),

        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.friend["avatar"]),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend["name"],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Active now",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.green,
                  ),
                ),
              ],
            )
          ],
        ),
      ),

      // ----------------------------------------------------------
      // ✅ Messages list
      // ----------------------------------------------------------
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                final isMe = msg["sender_id"] == myId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color:
                          isMe ? Colors.black87 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg["body"],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ----------------------------------------------------------
          // ✅ Input bar
          // ----------------------------------------------------------
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_emoticon,
                    color: Colors.black45),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: controller,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Message...",
                      hintStyle:
                          GoogleFonts.poppins(color: Colors.black38),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => send(),
                  ),
                ),

                GestureDetector(
                  onTap: send,
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
