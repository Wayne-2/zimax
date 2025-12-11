import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Map<String, dynamic>? selectedMessage;
  Map<String, dynamic>? replyTo;

  String _formatTime(String isoTime) {
    final dt = DateTime.parse(isoTime).toLocal();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

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
        WidgetsBinding.instance
            .addPostFrameCallback((_) => scrollToBottom());
      },
    )
        .subscribe();
  }

  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final uid = supabase.auth.currentUser!.id;

    await supabase.from("messages").insert({
      "chatroom_id": widget.roomId,
      "sender": uid,
      "message": text,
      "reply_to": replyTo != null ? replyTo!["id"] : null,
    });

    controller.clear();

    setState(() {
      replyTo = null;
    });
  }

  void scrollToBottom() {
    if (scroll.hasClients) {
      scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  void _showMessageMenu(BuildContext context, Map msg, bool isMe) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                setState(() => selectedMessage = null);
                Navigator.pop(context);
              },
              child: Container(color: Colors.transparent),
            ),

            Positioned(
              top: 200,
              right: isMe ? 20 : null,
              left: isMe ? null : 20,
              child: Material(
                color: Colors.white,
                elevation: 3,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _menuItem(Icons.reply, "Reply", () {
                      setState(() {
                        replyTo = msg as Map<String, dynamic>;
                        selectedMessage = null;
                      });
                      Navigator.pop(context);
                    }),
                    _menuItem(Icons.copy, "Copy", () {
                      Clipboard.setData(
                          ClipboardData(text: msg["message"]));
                    }),
                    if (isMe)
                      _menuItem(Icons.delete, "Delete", () {
                        _deleteMessage(msg["id"]);
                      }),
                    _menuItem(Icons.info_outline, "Info", () {}),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMessage(String id) async {
    await supabase.from("messages").delete().eq("id", id);

    setState(() {
      messages.removeWhere((m) => m["id"] == id);
      selectedMessage = null;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final myId = supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
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
        icon: const Icon(Icons.arrow_back,
            color: Color.fromARGB(255, 7, 7, 7)),
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
        final isSelected =
            selectedMessage != null && selectedMessage!["id"] == msg["id"];

        return GestureDetector(
          onLongPress: () {
            setState(() {
              selectedMessage = msg;
            });
            _showMessageMenu(context, msg, isMe);
          },

          onHorizontalDragEnd: (details) {
            if (!isMe && details.primaryVelocity! > 150) {
              // swipe right
              setState(() => replyTo = msg);
            }

            if (isMe && details.primaryVelocity! < -150) {
              // swipe left for sender
              setState(() => replyTo = msg);
            }
          },

          child: Container(
            color: isSelected
                ? Colors.black.withOpacity(0.08)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (msg["reply_to"] != null)
                  _buildReplyPreviewInsideBubble(msg["reply_to"], isMe),

                Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(top: 6, bottom: 2),
                    constraints: const BoxConstraints(maxWidth: 270),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color.fromARGB(255, 51, 51, 51)
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isMe
                            ? const Radius.circular(12)
                            : const Radius.circular(0),
                        bottomRight: isMe
                            ? const Radius.circular(0)
                            : const Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      msg["message"],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.3,
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4),
                  child: Text(
                    _formatTime(msg["created_at"]),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReplyPreviewInsideBubble(String replyId, bool isMe) {
    final replyMsg = messages
      .cast<Map<String, dynamic>>()
      .firstWhereOrNull((m) => m['id'] == replyId);

  if (replyMsg == null) return SizedBox.shrink();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(top: 6, bottom: 4),
        width: 220,
        decoration: BoxDecoration(
          color: const Color.fromARGB(200, 84, 84, 84),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 25,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                replyMsg["message"],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 10),
            Text(text, style: GoogleFonts.poppins(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: const Color.fromARGB(255, 243, 243, 243),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyTo != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 25,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      replyTo!["message"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() => replyTo = null);
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 6),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined,
                    color: Colors.black54),
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
                  icon: const Icon(Icons.arrow_upward_rounded,
                      color: Colors.white, size: 18),
                  onPressed: send,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
