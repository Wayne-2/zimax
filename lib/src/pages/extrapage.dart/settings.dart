import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: const [
          SectionHeader(title: 'ACCOUNT'),
          SettingsTile(icon: Icons.person_outline, title: 'Profile visibility'),
          SettingsTile(icon: Icons.lock_outline, title: 'Security'),
          SettingsTile(icon: Icons.verified_user_outlined, title: 'Verification'),

          SectionHeader(title: 'PRIVACY & SAFETY'),
          SettingsTile(icon: Icons.visibility_off_outlined, title: 'Privacy'),
          SettingsTile(icon: Icons.block_outlined, title: 'Blocked accounts'),
          SettingsTile(icon: Icons.report_outlined, title: 'Reports'),

          SectionHeader(title: 'CONTENT'),
          SettingsTile(icon: Icons.tune_outlined, title: 'Feed preferences'),
          SettingsTile(icon: Icons.language_outlined, title: 'Content language'),
          SettingsTile(icon: Icons.hide_source_outlined, title: 'Muted words'),

          SectionHeader(title: 'MESSAGING'),
          SettingsTile(icon: Icons.chat_outlined, title: 'Message controls'),
          SettingsTile(icon: Icons.mark_email_unread_outlined, title: 'Read receipts'),

          SectionHeader(title: 'NOTIFICATIONS'),
          SettingsTile(icon: Icons.notifications_outlined, title: 'Push notifications'),
          SettingsTile(icon: Icons.email_outlined, title: 'Email notifications'),

          SectionHeader(title: 'APPEARANCE'),
          SettingsTile(icon: Icons.dark_mode_outlined, title: 'Theme'),
          SettingsTile(icon: Icons.text_fields_outlined, title: 'Text size'),

          SectionHeader(title: 'DATA'),
          SettingsTile(icon: Icons.storage_outlined, title: 'Data usage'),
          SettingsTile(icon: Icons.download_outlined, title: 'Downloads'),

          SectionHeader(title: 'SUPPORT'),
          SettingsTile(icon: Icons.help_outline, title: 'Help center'),
          SettingsTile(icon: Icons.info_outline, title: 'About'),

          Divider(color: Colors.white12),
          SettingsTile(
            icon: Icons.delete_forever_outlined,
            title: 'Remove account',
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}


class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Color.fromARGB(96, 34, 34, 34),
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : Colors.black;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: GoogleFonts.poppins(color: color, fontSize: 14),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color.fromARGB(97, 60, 60, 60),
      ),
      onTap: () {},
    );
  }
}
