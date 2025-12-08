import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zimax/src/components/chatroom.dart';
import 'package:zimax/src/components/svgicon.dart';
import 'package:zimax/src/models/chatitem.dart';
import 'package:zimax/src/pages/extrapage.dart/addchat.dart';
import 'package:zimax/src/services/riverpod.dart';

class Chat extends ConsumerStatefulWidget {
  const Chat({super.key});

  @override
  ConsumerState<Chat> createState() => _ChatState();
}

class _ChatState extends ConsumerState<Chat>
    with TickerProviderStateMixin {

// ---- in your state class (keep existing fields for controllers/animations) ----

late AnimationController _introController;
late AnimationController _pulseController;

late Animation<double> slide;
late Animation<double> bounce;
late Animation<double> fade;
late Animation<double> pulse;

@override
void initState() {
  super.initState();

  // INTRO ANIMATION (bounce + fade + slide)
  _introController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  fade = CurvedAnimation(
    parent: _introController,
    curve: Curves.easeIn,
  );

  slide = Tween<double>(begin: 35, end: 0).animate(
    CurvedAnimation(parent: _introController, curve: Curves.easeOut),
  );

  bounce = Tween<double>(begin: 0.85, end: 1.0).animate(
    CurvedAnimation(parent: _introController, curve: Curves.elasticOut),
  );

  // PULSE ANIMATION (idle breathing effect)
  // Use a Tween mapped from the controller's 0..1 to the desired scale 0.97..1.03
  _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
    CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
  );

  // Start intro
  _introController.forward();

  // When intro completes, start the infinite pulse
  _introController.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      // start looping pulse (reverse: true for gentle breath)
      _pulseController.repeat(reverse: true);
    }
  });
}

@override
void dispose() {
  _introController.removeStatusListener((_) {}); // safe remove (no-op)
  _introController.dispose();
  _pulseController.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);

    final List<ChatItem> chats = [
        ChatItem(
          name: "elonmusk",
          preview: "Sure, send it.",
          avatar: "https://i.pravatar.cc/200?img=2",
          time: "22m ago",
          verified: true,
          online: true,
        ),
        ChatItem(
          name: "flutterdev",
          preview: "We’ll check and respond.",
          avatar: "https://i.pravatar.cc/200?img=11",
          time: "30m ago",
        ),
        ChatItem(
          name: "sundarpichai",
          preview: "Thanks!",
          avatar: "https://i.pravatar.cc/200?img=12",
          time: "2m ago",
          verified: true,
        ),
        ChatItem(
          name: "nextjsnews",
          preview: "New update just dropped.",
          avatar: "https://i.pravatar.cc/200?img=5",
          time: "2w ago",
        ),
      ];


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          "Zimax Chat",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
        ),

        actions: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: user!.pfp,
              width: 30,
              height: 30,
              fit: BoxFit.cover,

              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              errorWidget: (context, url, error) => Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade200,
                ),
                child: const Icon(Icons.person, color: Colors.grey, size: 16),
              ),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 226, 226, 226),
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search...',
                // contentPadding: EdgeInsets.zero,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(Icons.manage_search_sharp),
              ),
            ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Story',
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
        
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
        
              return _chatTile(
                name: chat.name,
                preview: chat.preview,
                avatar: chat.avatar,
                time: chat.time,
                online: chat.online,
                ontap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Chatroom(username: chat.name),
                    ),
                  );
                },
              );
            },
          ),
        ),]),


        floatingActionButton: Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          child: AnimatedBuilder(
            animation: Listenable.merge([_introController, _pulseController]),
            builder: (context, child) {
              final combinedScale = (bounce.value) * (pulse.value);
          
              return Opacity(
                opacity: fade.value,
                child: Transform.translate(
                  offset: Offset(0, slide.value),
                  child: Transform.scale(
                    scale: combinedScale,
                    child: child,
                  ),
                ),
              );
            },
          
            child: GestureDetector(
              onTap: () async {
                  final selected = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddChatPage()),
                  );
          
                  if (selected != null) {
                    print("Start chat with: $selected");
          
                }
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgIcon("assets/icons/newchat.svg", color: Colors.white, size: 25),
                    const SizedBox(width: 10),
                    Text(
                      "New",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
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
              CircleAvatar(radius: 26, backgroundImage: NetworkImage(image)),

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
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
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
    required String time,
    required VoidCallback ontap,
    bool online = false,
  }) {
    return GestureDetector(
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
                    top: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 60, 188),
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
                          fontSize: 14,
                        ),
                      ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.school,
                          color: Color.fromARGB(255, 0, 35, 192),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.circle, size: 6),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                  ),

                  const SizedBox(height: 2),
                  Text(
                    preview,
                    style: GoogleFonts.poppins(
                      color: Colors.black45,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
