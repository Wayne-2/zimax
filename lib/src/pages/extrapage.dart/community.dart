// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/components/svgicon.dart';
import 'package:zimax/src/models/postmodel.dart';
import 'package:zimax/src/pages/extrapage.dart/groupchat.dart';
import 'package:zimax/src/pages/extrapage.dart/preparelivesession.dart';

class Community extends StatefulWidget {
  final String communityId;
  const Community({super.key, required this.communityId});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  bool joined = false;
  bool loading = true;
  CommunityModel? community;
  int membersCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCommunityData();
  }

  Future<void> _fetchCommunityData() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    try {
      final communityRes = await supabase
          .from('communities')
          .select('*, community_rules(*)')
          .eq('id', widget.communityId)
          .single();

      final joinedRes = await supabase
          .from('community_members')
          .select()
          .eq('community_id', widget.communityId)
          .eq('user_id', userId)
          .maybeSingle();

      final membersRes = await supabase
          .from('community_members')
          .select('id')
          .eq('community_id', widget.communityId);

      setState(() {
        community = CommunityModel.fromMap(communityRes);
        joined = joinedRes != null;
        membersCount = (membersRes as List).length;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: loading
          ? _shimmerLoader()
          : CustomScrollView(
              slivers: [
                _collapsingBanner(),
                // SliverToBoxAdapter(child: _communityHeader()),
                SliverToBoxAdapter(child: _aboutSection()),
                SliverToBoxAdapter(child: _rulesSection()),
                SliverToBoxAdapter(child: _moderatorsBar()),
                SliverToBoxAdapter(child: _navigationTiles()),
              ],
            ),
    );
  }

  Widget _shimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        children: List.generate(
          5,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _collapsingBanner() {
    const double expanded = 260;

    return SliverAppBar(
      expandedHeight: expanded,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // Compute collapse factor t: 1.0 (expanded) -> 0.0 (collapsed)
          final double maxH = expanded + MediaQuery.of(context).padding.top;
          final double minH =
              kToolbarHeight + MediaQuery.of(context).padding.top;
          final double currentH = constraints.biggest.height;
          final double t = ((currentH - minH) / (maxH - minH)).clamp(0.0, 1.0);

          final String banner =
              community?.bannerUrl ?? 'https://via.placeholder.com/1200x600';
          final String avatar =
              community?.avatarUrl ?? 'https://via.placeholder.com/300';
          final String name = community?.name ?? '';

          final Color titleColor =
              Color.lerp(Colors.black, Colors.white, t) ?? Colors.black;
          final double avatarSize = lerpDouble(
            32,
            68,
            t,
          )!; // grows when expanded
          final double titleSize = lerpDouble(16, 22, t)!;
          final double btnRadius = lerpDouble(8, 10, t)!;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Background image with stretch/zoom and slight blur when over-stretched
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: banner,
                  fit: BoxFit.cover,
                  placeholder: (context, _) =>
                      Container(color: Colors.grey.shade300),
                  errorWidget: (context, _, __) =>
                      Container(color: Colors.grey.shade200),
                ),
              ),

              // Subtle blur on stretch
              if (t > 0.95)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: (t - 0.95) * 60,
                      sigmaY: (t - 0.95) * 60,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),

              // Gradient scrim for contrast
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.10 * t),
                        Colors.black.withOpacity(0.40 * t),
                        Colors.black.withOpacity(0.65 * t),
                      ],
                      stops: const [0.2, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Bottom divider only visible when collapsed
              Align(
                alignment: Alignment.bottomCenter,
                child: Opacity(
                  opacity: 1 - t,
                  child: Container(height: 1, color: Colors.grey.shade200),
                ),
              ),

              // Foreground content (avatar, title, button)
              Positioned(
                left: 12,
                right: 12,
                bottom: lerpDouble(
                  8,
                  16,
                  1 - t,
                )!, // slightly lower when collapsed
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Avatar with smooth scaling and shadow
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25 * t),
                            blurRadius: 14 * t,
                            offset: Offset(0, 6 * t),
                          ),
                        ],
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(avatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title + members
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: titleSize,
                              color: titleColor,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Opacity(
                            opacity:
                                0.9 * t +
                                0.5 * (1 - t), // keep slightly visible
                            child: Text(
                              '$membersCount members',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Color.lerp(
                                  Colors.grey.shade700,
                                  Colors.white70,
                                  t,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Join button: glassy on image, solid when collapsed
                    GestureDetector(
                      onTap: _toggleJoin,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: joined
                              ? Color.lerp(
                                  const Color(0xFF2B2A2A),
                                  Colors.white.withOpacity(0.18),
                                  t,
                                )
                              : Color.lerp(
                                  Colors.black,
                                  Colors.white.withOpacity(0.22),
                                  t,
                                ),
                          borderRadius: BorderRadius.circular(btnRadius),
                          border: Border.all(
                            color: Color.lerp(
                              Colors.transparent,
                              Colors.white.withOpacity(0.35),
                              t,
                            )!,
                          ),
                          boxShadow: [
                            if (t > 0.4)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15 * t),
                                blurRadius: 12 * t,
                                offset: Offset(0, 6 * t),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              joined ? 'Joined' : 'Join',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: t > 0.4 ? Colors.white : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // Native stretch behaviors (zoom/blur/fade title if you later use FlexibleSpaceBar)
      stretchTriggerOffset: 120,
      onStretchTrigger: () async {
        // Optional: refresh community data on pull-stretch
        // await _fetchCommunityData();
      },
    );
  }

  // -------------------- ABOUT SECTION --------------------
  Widget _aboutSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About Community",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            community?.description ?? '',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _rulesSection() {
    final rules = community?.rules ?? [];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Community Rules",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (rules.isEmpty)
            Text("No rules yet", style: GoogleFonts.poppins(fontSize: 13)),
          ...rules.map((r) => _ruleTile(r.ruleText)),
        ],
      ),
    );
  }

  Widget _ruleTile(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.black87),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rule,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moderatorsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SvgIcon('assets/commicon/admin.svg', color: Colors.black, size: 22),
          const SizedBox(width: 10),
          Text(
            "Moderators",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            "View all",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationTiles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _navTile('assets/commicon/groupchat.svg', "Group Chat", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Groupchat()),
            );
          }),
          const SizedBox(height: 12),
          _navTile('assets/commicon/stream.svg', "Live Sessions", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LiveClassSetupScreen()),
            );
          }),
          const SizedBox(height: 12),
          _navTile('assets/commicon/locker.svg', "Assets", () {}),
        ],
      ),
    );
  }

  Widget _navTile(String icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Row(
          children: [
            SvgIcon(icon, color: Colors.black, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleJoin() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    if (!joined) {
      await supabase.from('community_members').insert({
        'community_id': widget.communityId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });
    } else {
      await supabase
          .from('community_members')
          .delete()
          .eq('community_id', widget.communityId)
          .eq('user_id', userId);
    }

    setState(() => joined = !joined);
  }
}
