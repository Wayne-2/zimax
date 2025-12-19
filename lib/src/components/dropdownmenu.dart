import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show BorderRadius, BuildContext, Color, Colors, EdgeInsets, MaterialPageRoute, Navigator, PopupMenuButton, PopupMenuDivider, PopupMenuItem, RoundedRectangleBorder, Row, SizedBox, StatelessWidget, Text, Widget;
import 'package:google_fonts/google_fonts.dart';
import 'package:zimax/src/components/publicprofile.dart';

class PostOptionsMenu extends StatelessWidget {
  const PostOptionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_PostMenuAction>(
      padding: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      onSelected: (action) {
        switch (action) {
          case _PostMenuAction.follow:

            break;
          case _PostMenuAction.profile:
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Publicprofile()));
            break;
          case _PostMenuAction.report:

            break;
          case _PostMenuAction.block:
            break;
        }
      },
      itemBuilder: (context) => [
        _buildItem('Follow', _PostMenuAction.follow),
        _buildItem(
          'View profile',
          _PostMenuAction.profile,
        ),
        _buildItem(
          'Report user',
          _PostMenuAction.report,
        ),
        const PopupMenuDivider(),
        _buildItem(
          'Block',
          _PostMenuAction.block,
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<_PostMenuAction> _buildItem(
    String text,
    _PostMenuAction action, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: action,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: isDestructive ? Colors.red : const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PostMenuAction { follow, profile, report, block }
