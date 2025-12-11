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

  /// Load messages from Supabase
  Future<void> loadMessages() async {
    final res = await supabase
        .from("messages")
        .select()
        .eq("chatroom_id", widget.roomId)
        .order("created_at", ascending: true);

    setState(() {
      messages.clear();
      messages.addAll(List<Map<String, dynamic>>.from(res));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  /// Subscribe to realtime updates
  void subscribeRealtime() {
    channel = supabase.channel("room-${widget.roomId}");

    channel!
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: "public",
      table: "messages",
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: "chatroom_id",
        value: widget.roomId,
      ),
      callback: (payload) {
        final record = payload.newRecord;
        setState(() => messages.add(record));
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
      },
    )
        .subscribe();
  }

  /// Send message to Supabase
  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final uid = supabase.auth.currentUser!.id;

    await supabase.from("messages").insert({
      "chatroom_id": widget.roomId,
      "sender": uid,
      "message": text,
    });

    controller.clear();
  }

  /// Scroll helper
  void scrollToBottom() {
    if (scroll.hasClients) {
      scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: const Color(0xffece5dd),
      appBar: _buildWhatsAppAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessages(myId)),
          _buildInputBar(),
        ],
      ),
    );
  }

  AppBar _buildWhatsAppAppBar() {
    return AppBar(
      elevation: 0,
      leadingWidth: 50,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 7, 7, 7)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(widget.friend["avatar"]),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.friend["name"],
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 7, 7, 7),
                ),
              ),
              Text(
                "Online",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 7, 7, 7),
                ),
              ),
            ],
          )
        ],
      ),
      actions: const [
        Icon(Icons.call_outlined, color: Colors.black87, size: 20),
        SizedBox(width: 18),
        Icon(Icons.more_vert, color: Colors.black87),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessages(String myId) {
    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];
        final isMe = msg["sender"] == myId;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(top: 6, bottom: 4),
            constraints: const BoxConstraints(maxWidth: 270),
            decoration: BoxDecoration(
              color: isMe ? const Color.fromARGB(255, 51, 51, 51) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
              ),
            ),
            child: Text(
              msg["message"],
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color:isMe ? Colors.white: Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      color: const Color(0xfff0f0f0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.black54),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: controller,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Start typing...",
                  hintStyle: GoogleFonts.poppins(color: Colors.black38),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.black,
            child: IconButton(
              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 18),
              onPressed: send,
            ),
          ),
        ],
      ),
    );
  }
}
