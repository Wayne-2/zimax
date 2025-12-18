// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:hive/hive.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/appbar/profile.dart';
import 'package:zimax/src/auth/signin.dart';
import 'package:zimax/src/components/svgicon.dart';
// import 'package:zimax/src/models/chat_item_hive.dart';
import 'package:zimax/src/services/riverpod.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final username = user!.fullname;
    final status = user.status;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(3)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: CachedNetworkImage(
                      imageUrl: user.pfp,
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,

                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(45),
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
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Name + @handle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _getStatusIcon(status), // <- added clean badge icon
                        ],
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey[300]),

            const SizedBox(height: 10),

            // ---- Menu Items ----
            _buildMenuItem(
              icon: 'assets/appbaricon/profile.svg',
              label: "Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profilepage()),
                );
              },
            ),
            _buildMenuItem(
              icon: 'assets/appbaricon/settings.svg',
              label: "Settings",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: 'assets/appbaricon/notification.svg',
              label: "Notifications",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: 'assets/appbaricon/bookmark.svg',
              label: "Saved",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: 'assets/appbaricon/info.svg',
              label: "About",
              onTap: () {},
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ListTile(
                leading: Icon(Icons.logout, size: 18, color: Colors.redAccent),
                title: Text(
                  'Log Out',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
                onTap: () async {
                  // await Hive.box<ChatItemHive>('chatBox').clear();
                  // await Hive.box('settings').delete('last_uid');
                  await Supabase.instance.client.auth.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Signin()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable ListTile Builder
  Widget _buildMenuItem({
    required String icon,
    required String label,
    VoidCallback? onTap,
    Color color = const Color.fromARGB(255, 45, 45, 45),
  }) {
    return ListTile(
      leading: SvgIcon(icon, color: color, size: 22),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 13,
        color: const Color.fromARGB(255, 45, 45, 45),
      ),
      onTap: onTap,
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
