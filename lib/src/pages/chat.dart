import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:zimax/src/components/chatroom.dart';
import 'package:zimax/src/components/svgicon.dart';
import 'package:zimax/src/models/chat_item_hive.dart';
import 'package:zimax/src/models/chatitem.dart';
import 'package:zimax/src/pages/extrapage.dart/addchat.dart';
import 'package:zimax/src/services/riverpod.dart';



class Chat extends ConsumerStatefulWidget {
  const Chat({super.key});

  @override
  ConsumerState<Chat> createState() => _ChatState();
}

class _ChatState extends ConsumerState<Chat> with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  late Box<ChatItemHive> chatBox;
  List<ChatItemHive> chats = [];

  late AnimationController _intro;
  late AnimationController _pulse;
  late Animation<double> fade, slide, bounce, pulse;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadHive();
    _syncWithSupabase();
  }

  /// Load saved chats from Hive
  Future<void> _loadHive() async {
    chatBox = Hive.box<ChatItemHive>('chatBox');

    setState(() {
      chats = chatBox.values.toList();
      chats.sort((a, b) => b.time.compareTo(a.time));
    });
  }

  Future<void> _syncWithSupabase() async {
    final uid = supabase.auth.currentUser!.id;

    final rooms = await supabase
        .from('chatrooms')
        .select("""
          id,
          user1,
          user2,
          created_at,
          last_message:messages(limit:1, order:created_at.desc)
        """)
        .or('user1.eq.$uid,user2.eq.$uid');

    Map<String, ChatItemHive> merged = {
      for (var c in chats) c.roomId: c,
    };

    for (final r in rooms) {
      final otherId = r['user1'] == uid ? r['user2'] : r['user1'];

      /// Pull fresh user info
      final profile =
          await supabase.from('user_profile').select().eq('id', otherId).single();

      final lastMsg = r['last_message']?.isNotEmpty == true
          ? r['last_message'][0]['content']
          : "Start a conversation";

      final time = r['last_message']?.isNotEmpty == true
          ? r['last_message'][0]['created_at']
          : r['created_at'];

      merged[r['id']] = ChatItemHive(
        roomId: r['id'],
        userId: otherId,
        name: profile['fullname'],
        avatar: profile['profile_image_url'],
        preview: lastMsg,
        time: time,
        online: false,
      );

      await chatBox.put(r['id'], merged[r['id']]!);
    }

    setState(() {
      chats = merged.values.toList()
        ..sort((a, b) => b.time.compareTo(a.time));
    });
  }

  /// Create or retrieve a chatroom
  Future<String> getOrCreateRoom(String otherUserId) async {
    final myId = supabase.auth.currentUser!.id;

    final existing = await supabase
        .from('chatrooms')
        .select('id')
        .or('and(user1.eq.$myId,user2.eq.$otherUserId),and(user1.eq.$otherUserId,user2.eq.$myId)')
        .maybeSingle();

    if (existing != null) return existing['id'];

    final roomId = const Uuid().v4();

    await supabase.from('chatrooms').insert({
      "id": roomId,
      "user1": myId,
      "user2": otherUserId,
    });

    return roomId;
  }

  /// Add a chat from AddChatPage
  void addChat(ChatItem item) async {
    final roomId = await getOrCreateRoom(item.userId);

    final hiveItem = ChatItemHive(
      roomId: roomId,
      userId: item.userId,
      name: item.name,
      avatar: item.avatar,
      preview: item.preview,
      time: DateTime.now().toIso8601String(),
      online: item.online,
    );

    await chatBox.put(roomId, hiveItem);

    setState(() {
      chats.removeWhere((c) => c.roomId == roomId);
      chats.insert(0, hiveItem);
    });
  }

  /// Setup animations
  void _setupAnimations() {
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    fade = CurvedAnimation(parent: _intro, curve: Curves.easeIn);
    slide = Tween<double>(begin: 30, end: 0).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOut));
    bounce = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _intro, curve: Curves.elasticOut));
    pulse = Tween<double>(begin: 0.97, end: 1.03).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    _intro.forward();
    _intro.addStatusListener((s) {
      if (s == AnimationStatus.completed) _pulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  /// UI
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider)!;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("Zimax Chat",
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          CircleAvatar(
            radius: 16,
            backgroundImage: CachedNetworkImageProvider(user.pfp),
          ),
          const SizedBox(width: 16),
        ],
      ),

      body: Column(
        children: [
          _searchBar(),
          Padding( padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8), child: Row( mainAxisAlignment: MainAxisAlignment.start, children: [ Text( 'Story', style: GoogleFonts.poppins( color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14, ), ), ], ), ),
          _storyList(),
          _header(),
          _chatList(),
        ],
      ),

      floatingActionButton: _fab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _searchBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          height: 40,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 226, 226, 226),
            borderRadius: BorderRadius.circular(50),
          ),
          child: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search...',
              hintStyle: GoogleFonts.poppins(fontSize: 13),
              prefixIcon: const Icon(Icons.manage_search_sharp),
            ),
          ),
        ),
      );

  Widget _storyList() => SizedBox(
        height: 90,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(10),
          children: [
            _story("Engage", "https://i.pravatar.cc/200?img=1", add: true),
            _story("elonmusk", "https://i.pravatar.cc/200?img=2"),
            _story("flutterdev", "https://i.pravatar.cc/200?img=11"),
          ],
        ),
      );

Widget _story(String name, String img, {bool add = false}) => Padding(
  padding: const EdgeInsets.only(right: 10),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Stack(
        children: [
          CircleAvatar(radius: 22, backgroundImage: NetworkImage(img)), // was 26
          if (add)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.add, size: 12),
              ),
            ),
        ],
      ),
      const SizedBox(height: 4),
      SizedBox(
        width: 60,
        child: Text(
          name,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: GoogleFonts.poppins(fontSize: 12), // added
          textAlign: TextAlign.center,
        ),
      ),
    ],
  ),
);


  Widget _header() => Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Text("Conversations",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _chatList() {
    if (chats.isEmpty) {
      return const Expanded(
        child: Center(child: Text("Tap on New to start conversation")),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (_, i) => _chatTile(chats[i]),
      ),
    );
  }

  Widget _chatTile(ChatItemHive chat) => GestureDetector(
        onTap: () async {
          final roomId = await getOrCreateRoom(chat.userId);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Chatroom(
                roomId: roomId,
                friend: {
                  "id": chat.userId,
                  "name": chat.name,
                  "avatar": chat.avatar,
                },
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12, width: .4)),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(chat.avatar)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(chat.name,
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w500)),

                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(chat.preview,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              )
            ],
          ),
        ),
      );

  Widget _fab() => AnimatedBuilder(
        animation: Listenable.merge([_intro, _pulse]),
        builder: (_, child) {
          final scale = bounce.value * pulse.value;

          return Opacity(
            opacity: fade.value,
            child: Transform.translate(
              offset: Offset(0, slide.value),
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
        child: GestureDetector(
          onTap: () async {
            final ChatItem? item = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddChatPage()),
            );

            if (item != null) addChat(item);
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
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgIcon("assets/icons/newchat.svg", size: 25, color: Colors.white),
                const SizedBox(width: 10),
                const Text("New",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
}
