// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class Groupchat extends ConsumerStatefulWidget {


  const Groupchat({super.key,});

  @override
  ConsumerState<Groupchat> createState() => _GroupchatState();
}

class _GroupchatState extends ConsumerState<Groupchat> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child:_buildMessages(),
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
            backgroundImage: NetworkImage('https://picsum.photos/400/600'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group Testing',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 7, 7, 7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Group Description",
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
        Icon(Icons.notifications, color: Colors.black87, size: 20),
        SizedBox(width: 18),
        Icon(Icons.more_vert, color: Colors.black87),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessages() {

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 3,
      itemBuilder: (_, i) {
        return GestureDetector(
          onLongPress: () {},
          onHorizontalDragEnd: (details) {},
          child: Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(top: 6, bottom: 2),
                  constraints: const BoxConstraints(maxWidth: 270),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft:const Radius.circular(0),
                      bottomRight:const Radius.circular(12),
                    ),
                  ),
                  child: Text(
                   "message",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Text(
                    '12:00',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: const Color.fromARGB(255, 243, 243, 243),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Start typing...",
                      hintStyle: GoogleFonts.poppins(color: Colors.black38),
                      border: InputBorder.none,
                    ),
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
                  onPressed: (){},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
}