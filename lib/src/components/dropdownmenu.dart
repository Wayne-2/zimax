import 'package:flutter/material.dart' show PopupMenuItem, IconData, Row, Icons, StatelessWidget, BuildContext, Widget, Icon, PopupMenuDivider, Color, SizedBox, EdgeInsets, BorderRadius, RoundedRectangleBorder, PopupMenuButton, Colors, TextStyle, Text;

class PostOptionsMenu extends StatelessWidget {
  const PostOptionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_PostMenuAction>(
      icon: const Icon(
        Icons.more_vert,
        size: 18,
        color: Color(0xFF536471),
      ),
      padding: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (action) {
        switch (action) {
          case _PostMenuAction.follow:
            // TODO: follow user
            break;
          case _PostMenuAction.profile:
            // TODO: open profile
            break;
          case _PostMenuAction.report:
            // TODO: save post
            break;
          case _PostMenuAction.block:
            // TODO: block user
            break;
        }
      },
      itemBuilder: (context) => [
        _buildItem(
          Icons.person_add_alt_1,
          'Follow',
          _PostMenuAction.follow,
        ),
        _buildItem(
          Icons.account_circle_outlined,
          'View profile',
          _PostMenuAction.profile,
        ),
        _buildItem(
          Icons.report_outlined,
          'Report user',
          _PostMenuAction.report,
        ),
        const PopupMenuDivider(),
        _buildItem(
          Icons.block,
          'Block',
          _PostMenuAction.block,
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<_PostMenuAction> _buildItem(
    IconData icon,
    String text,
    _PostMenuAction action, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: action,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? Colors.red : const Color(0xFF0F1419),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDestructive ? Colors.red : const Color(0xFF0F1419),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PostMenuAction {
  follow,
  profile,
  report,
  block,
}
