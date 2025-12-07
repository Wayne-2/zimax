import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddChatPage extends StatefulWidget {
  const AddChatPage({super.key});

  @override
  State<AddChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<AddChatPage> {
  final TextEditingController _search = TextEditingController();
  String query = "";

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    final supabase = Supabase.instance.client;

    return supabase
        .from('user_profile')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) => rows.map((e) => e).toList());
  }

  @override
  Widget build(BuildContext context) {
    // final supabase = Supabase.instance.client;
    // final String myId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left, size: 22),
        ),
        title: Text(
          "New Conversations",
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: const [Icon(Icons.more_vert, size: 20), SizedBox(width: 15)],
      ),

      backgroundColor: Colors.white,

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _search,
                onChanged: (val) => setState(() => query = val),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search users",
                  hintStyle: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "Available on Zimax",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getUsersStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!;
                final String myId = Supabase.instance.client.auth.currentUser!.id;

                final filtered = users.where((u) {
                  final uid = u["id"]?.toString() ?? "";

                  if (uid == myId) return false;

                  final name = (u["fullname"] ?? "").toLowerCase();
                  final email = (u["email"] ?? "").toLowerCase();
                  final q = query.toLowerCase();

                  return name.contains(q) || email.contains(q);
                }).toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.only(top: 0),
                  itemBuilder: (context, i) {
                    final user = filtered[i];

                    final joinString = user["created_at"]?.toString();
                    DateTime joinDate = DateTime.tryParse(joinString ?? "") ?? DateTime.now();
                    final readable = DateFormat('d MMM yyyy').format(joinDate);

                    final status = user["status"];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundImage: user["profile_image_url"] != null
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
                          _getStatusIcon(status),
                          const SizedBox(width: 4),
                          Icon(Icons.circle, size: 4),
                          const SizedBox(width: 4),
                          Text(
                            'Joined in $readable',
                            style: GoogleFonts.poppins(
                              color: Color.fromARGB(188, 0, 0, 0),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        user["email"] ?? "No email",
                        style: GoogleFonts.poppins(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, user["username"]);
                      },
                    );
                  },
                );
              },
            ),
          )

        ],
      ),
    );
  }
}

Icon _getStatusIcon(String status) {
  switch (status) {
    case "Student":
      return const Icon(
        Icons.school,
        size: 18,
        color: Color.fromARGB(255, 0, 0, 254),
      );
    case "Academic Staff":
      return const Icon(
        Icons.star,
        size: 18,
        color: Color.fromARGB(255, 255, 208, 0),
      );
    case "Non-Academic Staff":
      return const Icon(
        Icons.work,
        size: 18,
        color: Color.fromARGB(255, 255, 0, 0),
      );
    case "Admin":
      return const Icon(
        Icons.verified,
        size: 18,
        color: Color.fromARGB(255, 2, 145, 19),
      );
    default:
      return const Icon(Icons.person, size: 18, color: Colors.grey);
  }
}