import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostsTab extends StatelessWidget {
  const PostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('No post yet', style:GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400)));
  }
}

class CommentsTab extends StatelessWidget {
  const CommentsTab({super.key});

  @override
  Widget build(BuildContext context) {
      return Center(child: Text('No Comments yet', style:GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400)));
  }
}

class BookmarkedTab extends StatelessWidget {
  const BookmarkedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('No bookmarks yet', style:GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400)));
  }
}

class MediaTab extends StatelessWidget {
  const MediaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('No media yet', style:GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400)));
  }
}
