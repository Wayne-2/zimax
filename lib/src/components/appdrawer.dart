import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          children: [

            // ---- Profile Section ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  // Profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      "https://i.pravatar.cc/300",
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Name + @handle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "John Doe",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "@johndoe",
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
              icon: Icons.person_outline,
              label: "Profile",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              label: "Settings",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.notifications_none,
              label: "Notifications",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.bookmark_outline,
              label: "Saved",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              label: "About",
              onTap: () {},
            ),

            const Spacer(),

            // ---- Bottom Logout Button ----
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildMenuItem(
                icon: Icons.logout,
                label: "Log Out",
                color: Colors.redAccent,
                onTap: () {},
              ),
            )
          ],
        ),
      ),
    );
  }

  // Reusable ListTile Builder
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}
