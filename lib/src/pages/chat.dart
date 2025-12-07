import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zimax/src/components/chatroom.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text(
          'Zimax Chats',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.notifications, color: Colors.black54, size: 18),
          SizedBox(width: 10),
          Icon(Icons.more_vert, color: Colors.black54, size: 22),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Engagements',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              children: [
                _storyItem(
                  name: "Engage",
                  image: "https://i.pravatar.cc/200?img=1",
                  isAdd: true,
                ),
                _storyItem(
                  name: "elonmusk",
                  image: "https://i.pravatar.cc/200?img=2",
                ),
                _storyItem(
                  name: "flutterdev",
                  image: "https://i.pravatar.cc/200?img=11",
                ),
                _storyItem(
                  name: "sundar",
                  image: "https://i.pravatar.cc/200?img=12",
                ),
                _storyItem(
                  name: "technews",
                  image: "https://i.pravatar.cc/200?img=5",
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Conversations',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _chatTile(
                name: "elonmusk",
                preview: "Sure, send it.",
                avatar: "https://i.pravatar.cc/200?img=2",
                verified: true,
                online: true,
                ontap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Chatroom(username: "flutterdev")),
                  );
                },
              ),
            ],
          ),
          _chatTile(
            name: "flutterdev",
            preview: "We’ll check and respond.",
            avatar: "https://i.pravatar.cc/200?img=11",
            ontap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Chatroom(username: "flutterdev")),
              );
            },
          ),
          _chatTile(
            name: "sundarpichai",
            preview: "Thanks!",
            avatar: "https://i.pravatar.cc/200?img=12",
            verified: true,
            ontap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Chatroom(username: "flutterdev")),
              );
            },
          ),
          _chatTile(
            name: "nextjsnews",
            preview: "New update just dropped.",
            avatar: "https://i.pravatar.cc/200?img=5",
            ontap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Chatroom(username: "flutterdev")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _storyItem({
    required String name,
    required String image,
    bool isAdd = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(radius: 24, backgroundImage: NetworkImage(image)),

              if (isAdd)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color.fromARGB(255, 0, 0, 0),
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 4),

          SizedBox(
            width: 60,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatTile({
    required String name,
    required String preview,
    required String avatar,
    required VoidCallback ontap,
    bool verified = false,
    bool online = false,
  }) {
    return InkWell(
      onTap: ontap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12, width: .4)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatar)),
                if (online)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 82, 188),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      if (verified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 2),

                  Text(
                    preview,
                    style: GoogleFonts.poppins(
                      color: Colors.black45,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }
}
