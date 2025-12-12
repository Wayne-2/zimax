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
import 'package:zimax/src/models/mediapost.dart';
import 'package:zimax/src/models/story.dart';
import 'package:zimax/src/pages/extrapage.dart/addchat.dart';
import 'package:zimax/src/pages/extrapage.dart/storypage.dart';
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

  List<StoryItem> stories = [];
  bool loading = true;

  RealtimeChannel? _channel;

  late AnimationController _intro;
  late AnimationController _pulse;
  late Animation<double> fade, slide, bounce, pulseAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadHive();
    _syncWithSupabase();
    loadStatus();
    subscribeRealtime();
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    _channel?.unsubscribe();
    super.dispose();
  }

  /// Load saved chats from Hive
  Future<void> _loadHive() async {
    chatBox = Hive.box<ChatItemHive>('chatBox');

    setState(() {
      chats = chatBox.values.toList();
      chats.sort((a, b) => b.time.compareTo(a.time));
    });
  }

  /// Sync chats with Supabase chatrooms
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

    Map<String, ChatItemHive> merged = {for (var c in chats) c.roomId: c};

    for (final r in rooms) {
      final otherId = r['user1'] == uid ? r['user2'] : r['user1'];
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

  /// Fetch status posts
  Future<void> loadStatus() async {
    final posts = await supabase
        .from('media_posts')
        .select()
        .eq('posted_to', 'Story')
        .order('created_at', ascending: true);

    final postList = List<Map<String, dynamic>>.from(posts);
    setState(() {
      stories = postList
          .map((json) => StoryItem(
                id: json['id'],
                name: json['username'] ?? '',
                avatar: json['pfp'],
                imageUrl: json['media_url'],
                text: json['content'],
              ))
          .toList();
      loading = false;
    });
  }

  /// Subscribe to Realtime updates for new status posts
  void subscribeRealtime() {
    _channel = supabase.channel('status_channel');

    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'media_posts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'posted_to',
            value: 'Story',
          ),
          callback: (payload) {
            final json = payload.newRecord;
            final newStory = StoryItem(
              id: json['id'],
              name: json['username'] ?? '',
              avatar: json['pfp'],
              imageUrl: json['media_url'],
              text: json['content'],
            );

            setState(() {
              if (!stories.any((s) => s.id == newStory.id)) stories.add(newStory);
            });
          },
        )
        .subscribe();
  }

  /// Generate StoryItems from MediaPosts (if needed elsewhere)
  List<StoryItem> mediaPostsToStories(List<MediaPost> posts) {
    return posts.map((post) {
      return StoryItem(
        id: post.id,
        name: post.username,
        avatar: post.pfp,
        imageUrl: post.mediaUrl,
        text: post.content,
      );
    }).toList();
  }

  /// Setup animations
  void _setupAnimations() {
    _intro = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _pulse = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));

    fade = CurvedAnimation(parent: _intro, curve: Curves.easeIn);
    slide = Tween<double>(begin: 30, end: 0)
        .animate(CurvedAnimation(parent: _intro, curve: Curves.easeOut));
    bounce = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _intro, curve: Curves.elasticOut));
    pulseAnim = Tween<double>(begin: 0.97, end: 1.03)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    _intro.forward();
    _intro.addStatusListener((s) {
      if (s == AnimationStatus.completed) _pulse.repeat(reverse: true);
    });
  }

  /// Create or get chat room
  Future<String> getOrCreateRoom(String otherUserId) async {
    final myId = supabase.auth.currentUser!.id;

    final existing = await supabase
        .from('chatrooms')
        .select('id')
        .or(
            'and(user1.eq.$myId,user2.eq.$otherUserId),and(user1.eq.$otherUserId,user2.eq.$myId)')
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
            style:
                GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
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
          storyList(context, user, stories),
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
      
Map<String, List<StoryItem>> groupStoriesByUser(List<StoryItem> stories) {
  final Map<String, List<StoryItem>> grouped = {};
  for (var story in stories) {
    if (!grouped.containsKey(story.name)) {
      grouped[story.name] = [];
    }
    grouped[story.name]!.add(story);
  }
  return grouped;
}

 Widget storyList(BuildContext context, dynamic user, List<StoryItem> stories) {
  if (loading) return const Center(child: CircularProgressIndicator());
  if (stories.isEmpty) return const Center(child: Text("No story available"));

  final groupedStories = groupStoriesByUser(stories);
  final userList = groupedStories.keys.toList();

  return SizedBox(
    height: 90,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: userList.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (_, index) {
        final username = userList[index];
        final userStories = groupedStories[username]!;
        final firstStory = userStories[0]; // Use first story as avatar

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StoryPage(
                  stories: userStories, // Pass only this user's stories
                  initialIndex: 0,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(firstStory.avatar ?? ''),
                    ),
                    if (userStories.length > 1)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          // padding: const EdgeInsets.all(2),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            // shape: BoxShape.circle,
                            border: Border.all(color:Colors.white),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Center(
                            child: Text(
                              '${userStories.length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  child: Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}


  Widget _header() => Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Text("Conversations",
              style:
                  GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
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

  Widget _chatTile(ChatItemHive chat) => InkWell(
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
                    Text(chat.name,
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(chat.preview,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.black54)),
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
          final scale = bounce.value * pulseAnim.value;

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
