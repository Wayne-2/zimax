import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/models/chatitem.dart';
import 'package:zimax/src/services/riverpod.dart';


class AddChatPage extends ConsumerStatefulWidget {
  const AddChatPage({super.key});

  @override
  ConsumerState<AddChatPage> createState() => _AddChatPageState();
}

class _AddChatPageState extends ConsumerState<AddChatPage> {
  final TextEditingController _search = TextEditingController();
  String query = "";
  final supabase = Supabase.instance.client;
  bool loading = false;
  Future<void> search(String query) async {
  final q = query.trim();

  setState(() => loading = true);

  try {


    final usersFuture = supabase
        .from('user_profile')
        .select()
        .or(
          'fullname.ilike.%$q%,email.ilike.%$q%,status.ilike.%$q%,profile_image_url.ilike.%$q%',
        )
        .order('created_at', ascending: false);

    await Future.wait([ usersFuture]);


  } catch (e) {
    debugPrint("Search error: $e");
  } finally {
    setState(() => loading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userServiceStreamProvider);
    final myUser = Supabase.instance.client.auth.currentUser;
    final myId = myUser?.id;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left, size: 22, color: Colors.black),
        ),
        title: Text(
          "New Conversations",
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: Column(
        children: [
          _buildSearchBar(),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Available on Zimax",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Expanded(
            child: usersAsync.when(
              loading: () => _buildShimmerList(),
              error: (e, _) => Center(child: Text("Error: $e")),
              data: (users) {
                // FILTER OUT CURRENT USER
                final filtered = users.where((u) => u["id"] != myId).toList();

                // SEARCH FILTER
                final q = query.toLowerCase();
                final searched = filtered.where((u) {
                  final name = (u["fullname"] ?? "").toLowerCase();
                  final email = (u["email"] ?? "").toLowerCase();
                  return name.contains(q) || email.contains(q);
                }).toList();

                if (searched.isEmpty) {
                  return Center(
                    child: Text(
                      "No users found",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: searched.length,
                  itemBuilder: (context, index) {
                    final user = searched[index];
                    return _buildUserTile(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey.shade200,
        ),
        child: TextField(
          controller: _search,
          onChanged: (v) => setState(() => query = v),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Search users",
            hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
            prefixIcon: Icon(Icons.manage_search_sharp),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(Map user) {
    final joinDate = DateTime.tryParse(user["created_at"] ?? "") ?? DateTime.now();
    final readable = DateFormat("d MMM yyyy").format(joinDate);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      leading: CircleAvatar(
        radius: 22,
        backgroundImage: (user["profile_image_url"] != null &&
                user["profile_image_url"] != "")
            ? NetworkImage(user["profile_image_url"])
            : const NetworkImage("https://i.pravatar.cc/150?img=3"),
      ),

      title: Row(
        children: [
          Text(
            user["fullname"] ?? "Unknown User",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          _buildStatusIcon(user["status"] ?? ""),
          const SizedBox(width: 4),
          const Icon(Icons.circle, size: 4, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            "Joined $readable",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),

      subtitle: Text(
        user["email"] ?? "No email",
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.black45,
        ),
      ),
        onTap: () {
          final chatItem = ChatItem(
            name: user["fullname"],
            preview: "Start a conversation",
            avatar: user["profile_image_url"] ?? "",
            userId: user["id"],
            time: "now",
            verified: user["status"] == "verified",
            online: user["status"] == "online",
          );

          Navigator.pop(context, chatItem);
        }
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => shimmerTile(),
    );
  }

  Icon _buildStatusIcon(String status) {
    switch (status) {
      case "Student":
        return const Icon(Icons.school, size: 18, color: Colors.blue);
      case "Academic Staff":
        return const Icon(Icons.star, size: 18, color: Colors.amber);
      case "Non-Academic Staff":
        return const Icon(Icons.work, size: 18, color: Colors.red);
      case "Admin":
        return const Icon(Icons.verified, size: 18, color: Colors.green);
      default:
        return const Icon(Icons.person, size: 18, color: Colors.grey);
    }
  }
}

Widget shimmerTile() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 160,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
