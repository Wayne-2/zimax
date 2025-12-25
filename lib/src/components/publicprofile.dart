import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/services/follow_service.dart';
import 'package:zimax/src/services/riverpod.dart';

class Publicprofile extends ConsumerStatefulWidget {
  final String userId;
  const Publicprofile({super.key, required this.userId});

    Future<void> followOrRequest(String targetId, bool isPrivate) async {
  final uid = Supabase.instance.client.auth.currentUser!.id;

  if (isPrivate) {
    await Supabase.instance.client.from('follow_requests').insert({
      'requester_id': uid,
      'target_id': targetId,
    });
  } else {
    await Supabase.instance.client.from('follows').insert({
      'follower_id': uid,
      'following_id': targetId,
    });
  }
}

Future<void> unfollowUser(String targetId) async {
  final uid = Supabase.instance.client.auth.currentUser!.id;

  await Supabase.instance.client
      .from('follows')
      .delete()
      .eq('follower_id', uid)
      .eq('following_id', targetId);
}


  @override
  ConsumerState<Publicprofile> createState() => _PublicprofileState();
}

class _PublicprofileState extends ConsumerState<Publicprofile>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
    final userProfileAsync = ref.watch(publicUserProfileProvider(widget.userId));
  
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: userProfileAsync.when(
          data: (user) => Text(
            user.fullname.toLowerCase().replaceAll(" ", "_"),
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
        centerTitle: true,
      ),
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
        error: (_, __) => _ErrorState(),
        data: (user) => _ProfileView(user: user, tabController: _tabController),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final dynamic user;
  final TabController tabController;

  const _ProfileView({required this.user, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Top Row: Avatar + Stats
                Row(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: NetworkImage(user.pfp),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        _ProfileStat(count: "0", label: "Posts"),
                        _ProfileStat(count: "${user.followerCount}", label: "Followers"),
                        _ProfileStat(count: "${user.followingCount}", label: "Following"),

                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Name and Bio
                Text(
                  user.fullname,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user.department,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.bio,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, _) {
                          final currentUserId =
                              Supabase.instance.client.auth.currentUser!.id;

                          if (currentUserId == user.id) {
                            return const SizedBox();
                          }

                          final isFollowing =
                              ref.watch(followStatusProvider(user.id));
                          final isRequested =
                              ref.watch(followRequestProvider(user.id));

                          return isFollowing.when(
                            loading: () => _ActionButton(
                              label: "Loading...",
                              onPressed: () {},
                              isPrimary: true,
                            ),
                            error: (_, __) => _ActionButton(
                              label: "Error",
                              onPressed: () {},
                              isPrimary: true,
                            ),
                            data: (following) {
                              if (following) {
                                return _ActionButton(
                                  label: "Following",
                                  isPrimary: false,
                                  onPressed: () async {
                                    await FollowService.unfollow(user.id);
                                    ref.invalidate(followStatusProvider(user.id));
                                  },
                                );
                              }

                              return isRequested.when(
                                loading: () => _ActionButton(
                                  label: "Loading...",
                                  onPressed: () {},
                                  isPrimary: true,
                                ),
                                error: (_, __) => _ActionButton(
                                  label: "Error",
                                  onPressed: () {},
                                  isPrimary: true,
                                ),
                                data: (requested) => _ActionButton(
                                label: requested ? "Requested" : "Follow",
                                isPrimary: !requested,
                                onPressed: requested 
                                  ? null // This will disable the button
                                  : () async {
                                      await FollowService.followOrRequest(
                                        user.id,
                                        user.isPrivate,
                                      );
                                      ref.invalidate(followStatusProvider(user.id));
                                      ref.invalidate(followRequestProvider(user.id));
                                    },
                              ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: "Chat user",
                        onPressed: () {},
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabDelegate(tabController),
        ),
      ],
      body: TabBarView(
        controller: tabController,
        children: [
          
          const Center(child: Text("Posts")),
          const Center(child: Text("Comments")),
          _ImageGrid(userId: user.id),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* COMPONENTS                                 */
/* -------------------------------------------------------------------------- */

class _ProfileStat extends StatelessWidget {
  final String count;
  final String label;
  const _ProfileStat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // Make nullable
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isPrimary ? Colors.black : Colors.grey.shade100,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isPrimary ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final String userId;
  const _ImageGrid({required this.userId});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 15, // Placeholder
      itemBuilder: (context, index) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.collections_outlined, color: Colors.white, size: 30),
      ),
    );
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final TabController controller;
  _SliverTabDelegate(this.controller);

  @override
  double get minExtent => 45;
  @override
  double get maxExtent => 45;

  @override
  Widget build(_, __, ___) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: TabBar(
        controller: controller,
        indicatorColor: Colors.black,
        indicatorWeight: 1.5,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey.shade400,
        tabs: [
          Tab(text: 'Posts',),
          Tab(text: 'Comments',),
          Tab(text: 'Media',),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_) => false;
}

class _ErrorState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Profile unavailable', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Go Back")),
        ],
      ),
    );
  }
}