// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/models/chat_item_hive.dart';
import 'package:zimax/src/services/riverpod.dart';

class Chatroom extends ConsumerStatefulWidget {
  final String roomId;
  final Map friend;

  const Chatroom({
    super.key,
    required this.roomId,
    required this.friend,
  });

  @override
  ConsumerState<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends ConsumerState<Chatroom> {
  final supabase = Supabase.instance.client;
  late Box<ChatItemHive> chatBox;

  Map<String, dynamic>? selectedMessage;
  Map<String, dynamic>? replyTo;

  final List<Map<String, dynamic>> messages = [];
  final ScrollController scroll = ScrollController();
  final TextEditingController controller = TextEditingController();

  RealtimeChannel? channel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChatroom();
  }

  @override
  void dispose() {
    channel?.unsubscribe();
    controller.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> _initializeChatroom() async {
    try {
      chatBox = Hive.box<ChatItemHive>('chatBox');
      await loadMessages();
      subscribeRealtime();
      
      // Mark messages as read
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatPreviewProvider.notifier).markAsRead(widget.roomId);
      });
    } catch (e) {
      debugPrint('Error initializing chatroom: $e');
    }
  }

  Future<void> loadMessages() async {
    try {
      setState(() => isLoading = true);

      final res = await supabase
          .from("messages")
          .select()
          .eq("chatroom_id", widget.roomId)
          .order("created_at", ascending: true);

      if (mounted) {
        setState(() {
          messages.clear();
          messages.addAll(List<Map<String, dynamic>>.from(res));
          isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  void subscribeRealtime() {
    final myId = supabase.auth.currentUser?.id;
    if (myId == null) return;

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
      callback: (payload) async {
        try {
          final record = payload.newRecord;
          final isMine = record['sender'] == myId;

          // Only add if not already in local messages
          if (!messages.any((m) => m['id'] == record['id'])) {
            if (mounted) {
              setState(() => messages.add(record));
            }

            // Update Hive chat preview for all messages
            await _updateChatPreviewInHive(
              record['message'] as String,
              record['created_at'] as String,
            );

            // Update Riverpod provider for unread count
            if (!isMine) {
              ref.read(chatPreviewProvider.notifier).onNewMessage(
                    chatroomId: widget.roomId,
                    message: record['message'],
                    createdAt: DateTime.parse(record['created_at']),
                    isMine: false,
                  );
            }
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) scrollToBottom();
          });
        } catch (e) {
          debugPrint('Error processing realtime message: $e');
        }
      },
    )
        .subscribe();
  }

  /// Update chat preview in Hive
  Future<void> _updateChatPreviewInHive(
    String message,
    String timestamp,
  ) async {
    try {
      final existingChat = chatBox.get(widget.roomId);

      if (existingChat != null) {
        final updatedChat = ChatItemHive(
          roomId: existingChat.roomId,
          userId: existingChat.userId,
          name: existingChat.name,
          avatar: existingChat.avatar,
          preview: message,
          time: timestamp,
          online: existingChat.online,
        );

        await chatBox.put(widget.roomId, updatedChat);
      } else {
        // If chat doesn't exist in Hive, create it
        final newChat = ChatItemHive(
          roomId: widget.roomId,
          userId: widget.friend['id'],
          name: widget.friend['name'],
          avatar: widget.friend['avatar'],
          preview: message,
          time: timestamp,
          online: false,
        );

        await chatBox.put(widget.roomId, newChat);
      }
    } catch (e) {
      debugPrint('Error updating chat preview in Hive: $e');
    }
  }

  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    try {
      // Insert message and return the inserted record
      final inserted = await supabase.from("messages").insert({
        "chatroom_id": widget.roomId,
        "sender": uid,
        "message": text,
        "reply_to": replyTo?["id"],
      }).select().single();

      controller.clear();

      if (mounted) {
        setState(() {
          replyTo = null;
          // Only add if not already present (realtime might add it first)
          if (!messages.any((m) => m['id'] == inserted['id'])) {
            messages.add(inserted);
          }
        });
      }

      // Update Hive with the new message preview
      await _updateChatPreviewInHive(
        inserted["message"],
        inserted["created_at"],
      );

      // Update Riverpod provider for outgoing message
      ref.read(chatPreviewProvider.notifier).onNewMessage(
            chatroomId: widget.roomId,
            message: inserted["message"],
            createdAt: DateTime.parse(inserted["created_at"]),
            isMine: true,
          );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) scrollToBottom();
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
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
      barrierColor: Colors.black26,
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
                      Clipboard.setData(ClipboardData(text: msg["message"]));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message copied'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }),
                    if (isMe)
                      _menuItem(Icons.delete, "Delete", () {
                        _deleteMessage(msg["id"]);
                      }),
                    _menuItem(Icons.info_outline, "Info", () {
                      Navigator.pop(context);
                      _showMessageInfo(context, msg);
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessageInfo(BuildContext context, Map msg) {
    final createdAt = DateTime.parse(msg['created_at']).toLocal();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Message Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sent: ${_formatFullDate(createdAt)}'),
            const SizedBox(height: 8),
            Text('Time: ${_formatTime(msg['created_at'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  Future<void> _deleteMessage(String id) async {
    try {
      await supabase.from("messages").delete().eq("id", id);

      if (mounted) {
        setState(() {
          messages.removeWhere((m) => m["id"] == id);
          selectedMessage = null;
        });

        // Update Hive with the new last message if this was the last one
        if (messages.isNotEmpty) {
          final lastMessage = messages.last;
          await _updateChatPreviewInHive(
            lastMessage['message'],
            lastMessage['created_at'],
          );
        } else {
          // If no messages left, update with default message
          await _updateChatPreviewInHive(
            "Start a conversation",
            DateTime.now().toIso8601String(),
          );
        }

        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error deleting message: $e');
      // if (mounted) {
      //   Navigator.pop(context);
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Failed to delete message: ${e.toString()}'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // }
    }
  }

  String _formatTime(String isoTime) {
    final dt = DateTime.parse(isoTime).toLocal();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final myId = supabase.auth.currentUser?.id;

    if (myId == null) {
      return const Scaffold(
        body: Center(child: Text('Authentication error')),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMessages(myId),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend["name"],
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 7, 7, 7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Online",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 100, 100, 100),
                  ),
                ),
              ],
            ),
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
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Start the conversation!',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];
        final isMe = msg["sender"] == myId;
        final isSelected =
            selectedMessage != null && selectedMessage!["id"] == msg["id"];

        return GestureDetector(
          onLongPress: () {
            setState(() => selectedMessage = msg);
            _showMessageMenu(context, msg, isMe);
          },
          onHorizontalDragEnd: (details) {
            if (!isMe && details.primaryVelocity! > 150) {
              setState(() => replyTo = msg);
            }
            if (isMe && details.primaryVelocity! < -150) {
              setState(() => replyTo = msg);
            }
          },
          child: Container(
            color: isSelected
                ? Colors.black.withOpacity(0.08)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 2),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (msg["reply_to"] != null)
                  _buildReplyPreviewInsideBubble(msg["reply_to"], isMe),
                Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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

    if (replyMsg == null) return const SizedBox.shrink();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(top: 6, bottom: 4),
        constraints: const BoxConstraints(maxWidth: 220),
        decoration: BoxDecoration(
          color: const Color.fromARGB(200, 84, 84, 84),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
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
                  color: Colors.white70,
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
          if (replyTo != null) _buildReplyPreview(),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined,
                    color: Colors.black54),
                onPressed: () {
                  // TODO: Implement emoji picker
                },
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
                    maxLines: null,
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

  Widget _buildReplyPreview() {
    if (replyTo == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              color: Colors.black,
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
    );
  }
}