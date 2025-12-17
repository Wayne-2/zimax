import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Make sure to add google_fonts package in pubspec.yaml

class Publicprofile extends StatelessWidget {
  const Publicprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(), // Set Poppins for all texts
      ),
      home: const RedditProfilePage(),
    );
  }
}

class RedditProfilePage extends StatefulWidget {
  const RedditProfilePage({super.key});

  @override
  _RedditProfilePageState createState() => _RedditProfilePageState();
}

class _RedditProfilePageState extends State<RedditProfilePage>
    with SingleTickerProviderStateMixin {
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 1. Image Banner with Return Button
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color.fromARGB(255, 173, 173, 173),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  'https://picsum.photos/400/250',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 2. Profile Overlap Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 16),
                    _buildBio(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),

            // 3. High-Contrast TabBar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey.shade400,
                  indicatorColor: Colors.black,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
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

  Widget _buildProfileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ALEX RIVERA",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                color: Colors.black,
              ),
            ),
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
      ],
    );
  }

  Widget _buildBio() {
    return Text(
      "Crafting digital experiences with Flutter. Minimalist by choice, developer by passion. Based in London.",
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: Colors.black87,
        height: 1.5,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
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
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.mail_outline, color: Colors.black, size: 22),
            onPressed: () {},
          ),
        ),
      ],
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
              fontSize: 16,
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
