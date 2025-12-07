import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Chatroom extends StatefulWidget {
  final String username;

  const Chatroom({super.key, required this.username});

  @override
  State<Chatroom> createState() => _ChatPageState();
}

class _ChatPageState extends State<Chatroom> {
  final List<Map<String, dynamic>> messages = [
    {"fromMe": false, "text": "Hey 👋"},
    {"fromMe": true, "text": "Hi!"},
    {"fromMe": false, "text": "How are you?"},
    {"fromMe": true, "text": "Doing great, you?"},
  ];

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const Icon(Icons.chevron_left, color: Colors.black),

        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage:
                  NetworkImage("https://i.pravatar.cc/200?u=${widget.username}"),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Active now",
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.green),
                )
              ],
            )
          ],
        ),

        actions: const [
          Icon(Icons.call, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];

                return Align(
                  alignment:
                      msg["fromMe"] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    constraints: const BoxConstraints(maxWidth: 250),

                    decoration: BoxDecoration(
                      color:
                          msg["fromMe"] ? const Color.fromARGB(255, 29, 29, 29) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Text(
                      msg["text"] ,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: msg["fromMe"] ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Input Row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 218, 218, 218),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black12),
            ),
          
            child: Row(
              children: [
                Icon(Icons.insert_emoticon, color: Colors.black45, size: 20),
          
                const SizedBox(width: 8),
          
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
          
                    decoration: InputDecoration(
                      hintText: "Message...",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
          
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
          
                const SizedBox(width: 6),
          
                GestureDetector(
                  onTap: () {
                    if (controller.text.trim().isEmpty) return;
          
                    setState(() {
                      messages.add({
                        "fromMe": true,
                        "text": controller.text.trim(),
                      });
                      controller.clear();
                    });
                  },
          
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Color.fromARGB(255, 0, 0, 0),
                    size: 18,
                  ),
                )
              ],
            ),
          )

        ],
      ),
    );
  }
}
