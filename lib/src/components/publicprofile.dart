import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Publicprofile extends StatefulWidget {
  const Publicprofile({super.key});

  @override
  State<Publicprofile> createState() => _PublicprofileState();
}

class _PublicprofileState extends State<Publicprofile> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Top section with back button and avatar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
                child: Column(
                  children: [
                    // Back button aligned to left
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Centered avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/200', // Replace with user's pfp
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Name
                    Text(
                      "ALEX RIVERA",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Username / Role
                    Text(
                      "@alex_dev • Developer",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Bio
                      Text(
                        "Crafting digital experiences with Flutter. Minimalist by choice, developer by passion. Based in London.",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Followers / Following Section
                      Row(
                        children: [
                          _buildStat("210", "Followers"),
                          const SizedBox(width: 24),
                          _buildStat("180", "Following"),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                "Follow",
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.mail_outline, color: Colors.black),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

                          // Sticky TabBar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey.shade400,
                  indicatorColor: Colors.black,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: "Posts"),
                    Tab(text: "Media"),
                    Tab(text: "Links"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostList(),
            const Center(child: Text("Gallery View")),
            const Center(child: Text("External Links")),
          ],
        ),
      ),
    );
  }

  Widget _buildPostList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: 5,
      itemBuilder: (context, index) => _buildPostItem(),
    );
  }

  Widget _buildPostItem() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "The beauty of black and white lies in its ability to strip away the noise and focus on the essence of the design.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 18),
              const SizedBox(width: 5),
              const Text("24", style: TextStyle(fontSize: 13)),
              const SizedBox(width: 25),
              const Icon(Icons.mode_comment_outlined, size: 18),
              const SizedBox(width: 5),
              const Text("12", style: TextStyle(fontSize: 13)),
              const Spacer(),
              Icon(Icons.bookmark_border, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String count, String label) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        count,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(width: 10),
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
    ],
  );
}

}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) => false;
}
