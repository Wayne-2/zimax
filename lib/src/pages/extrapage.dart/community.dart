import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  bool joined = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _collapsingBanner(),
          SliverToBoxAdapter(child: _communityHeader()),
          SliverToBoxAdapter(child: _aboutSection()),
          SliverToBoxAdapter(child: _rulesSection()),
          SliverToBoxAdapter(child: _moderatorsBar()),
          _postList(),
        ],
      ),
    );
  }

  Widget _collapsingBanner() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: Colors.white,

      // COLLAPSED HEADER (shows only when scrolled)
      title: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed = constraints.maxHeight < 120;

          return AnimatedOpacity(
            opacity: isCollapsed ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: CachedNetworkImageProvider(
                    "https://kldaeoljhumowuegwjyq.supabase.co/storage/v1/object/public/media/zimaxpfp.png",
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Zimax Collaborators",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => joined = !joined),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: joined ? Colors.grey.shade800 : Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      joined ? "Joined" : "Join",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl:
              "https://kldaeoljhumowuegwjyq.supabase.co/storage/v1/object/public/media/zimaxpfp.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // --------------------------------------------------
  //  MAIN COMMUNITY HEADER (visible when expanded)
  // --------------------------------------------------
  Widget _communityHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: CachedNetworkImageProvider(
              "https://kldaeoljhumowuegwjyq.supabase.co/storage/v1/object/public/media/zimaxpfp.png",
            ),
          ),
          const SizedBox(width: 16),

          // NAME + MEMBER COUNT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Zimax Collaborators",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                Text(
                  "350k members · 1.2k online",
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // JOIN BUTTON
          ElevatedButton(
            onPressed: () => setState(() => joined = !joined),
            style: ElevatedButton.styleFrom(
              backgroundColor: joined ? Colors.grey.shade800 : Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              side:
                  joined ? const BorderSide(color: Colors.black, width: 1) : null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              joined ? "Joined" : "Join",
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  //  ABOUT SECTION
  // --------------------------------------------------
  Widget _aboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("About Community",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            "Welcome to Zimax Collaborators and development team, "
            "the platform gives room for respectable suggestion and "
            "information for the further development of the application.",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                "Created Jan 2019",
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  //  COMMUNITY RULES
  // --------------------------------------------------
  Widget _rulesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Community Rules",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 10),
          _ruleTile("Be respectful to others."),
          _ruleTile("No spam posts."),
          _ruleTile("Post Flutter-related content only."),
        ],
      ),
    );
  }

  Widget _ruleTile(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: Text(rule,
                style:
                    GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  //  MODERATORS ROW
  // --------------------------------------------------
  Widget _moderatorsBar() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.black87),
          const SizedBox(width: 10),
          Text("Moderators",
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text("View all",
              style:
                  GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700))
        ],
      ),
    );
  }

  // --------------------------------------------------
  //  POST LIST
  // --------------------------------------------------
  Widget _postList() {
    final posts = List.generate(1, (i) => i);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _postCard(index),
        childCount: posts.length,
      ),
    );
  }

  // --------------------------------------------------
  //  SINGLE POST CARD
  // --------------------------------------------------
  Widget _postCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: CachedNetworkImageProvider(
                  "https://i.pravatar.cc/200?img=${index + 5}",
                ),
              ),
              const SizedBox(width: 10),
              Text("user${index + 1}",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 6),
              Text("· 5h ago",
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            "This is a sample post inside the Flutter community. Index = $index",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl:
                  "https://images.unsplash.com/photo-1503264116251-35a269479413",
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _iconWithLabel(Icons.arrow_upward, "Vote"),
              _iconWithLabel(Icons.comment, "123"),
              _iconWithLabel(Icons.share, "Share"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconWithLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey.shade700)),
      ],
    );
  }
}
