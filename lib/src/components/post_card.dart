// ignore_for_file: avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/components/commentsheets.dart';
import 'package:zimax/src/components/dropdownmenu.dart';
import 'package:zimax/src/components/repostingbutton.dart';
import 'package:zimax/src/components/sharebottomsheet.dart';
import 'package:zimax/src/components/svgicon.dart';

class PostCard extends StatefulWidget {
  final String username;
  final String department;
  final String status;
  final String pfp;
  final String postId;
  final String postcontent;
  final String? imageUrl;
  final String repost;
  final String like;
  final String comment;
  final String poll;
  final DateTime createdAt;

  const PostCard({
    super.key,
    required this.username,
    required this.department,
    required this.status,
    required this.pfp,
    required this.postId,
    required this.postcontent,
    required this.repost,
    required this.like,
    required this.comment,
    required this.poll,
    this.imageUrl,
    required this.createdAt,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  void _openCommentsSheet(BuildContext context, String postId) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;
    print(widget.comment);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CommentSheet(postId: postId, userId: user.id);
      },
    );
  }

  void _openShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ShareBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readableDate = timeAgo(widget.createdAt);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: CachedNetworkImage(
                      imageUrl: widget.pfp,
                      width: 35,
                      height: 35,
                      fit: BoxFit.cover,

                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                      ),

                      errorWidget: (context, url, error) => Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey.shade200,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.username} ",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 4),
                          _buildStatusIcon(widget.status),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.department,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.circle, size: 3),
                          SizedBox(width: 4),
                          Text(
                            '$readableDate ',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const PostOptionsMenu(),
            ],
          ),

          const SizedBox(height: 4),

          if (widget.imageUrl != null) ...[
            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                height: 300,
                width: double.infinity,
                imageUrl: widget.imageUrl!,
                fit: BoxFit.cover,

                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),

                errorWidget: (context, url, error) => Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          Text(
            widget.postcontent,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _ActivIcon(
                icon: 'assets/activicon/comment.svg',
                count: widget.comment,
                onTap: () => _openCommentsSheet(context, widget.postId),
              ),
              const SizedBox(width: 20),
              RepostButton(count: widget.repost),
              const SizedBox(width: 20),
              LikeButton(
                count: widget.like,
                initialLiked: false, // or pass your backend like state
              ),
              const SizedBox(width: 20),
              _ActivIcon(
                icon: 'assets/activicon/activity.svg',
                count: widget.poll,
                onTap: () {},
              ),
              const Spacer(),
              BookmarkButton(),
              const SizedBox(width: 14),
              _ActivIcon(
                icon: 'assets/activicon/share.svg',
                count: '',
                onTap: () => _openShareSheet(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Icon _buildStatusIcon(String status) {
  switch (status) {
    case "Student":
      return const Icon(
        Icons.school,
        size: 18,
        color: Color.fromARGB(255, 0, 4, 255),
      );
    case "Academic Staff":
      return const Icon(Icons.star, size: 18, color: Colors.amber);
    case "Non-Academic Staff":
      return const Icon(Icons.work, size: 18, color: Colors.red);
    case "Admin":
      return const Icon(Icons.verified, size: 18, color: Colors.green);
    default:
      return const Icon(Icons.person, size: 18, color: Colors.grey);
  }
}

String timeAgo(DateTime createdAt) {
  final now = DateTime.now();
  final diff = now.difference(createdAt);

  if (diff.inSeconds < 60) {
    return "just now";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} min ago";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} hr ago";
  } else if (diff.inDays == 1) {
    return "Yesterday";
  } else {
    return "${diff.inDays} days ago";
  }
}

class _ActivIcon extends StatelessWidget {
  final String icon;
  final String count;
  final VoidCallback? onTap;

  const _ActivIcon({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SvgIcon(icon, color: const Color.fromARGB(255, 24, 24, 24), size: 18),
          if (count.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              count,
              style: const TextStyle(
                color: Color.fromARGB(255, 46, 46, 46),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LikeButton extends StatefulWidget {
  final String count;
  final bool initialLiked;

  const LikeButton({super.key, required this.count, this.initialLiked = false});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late bool isLiked;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    isLiked = widget.initialLiked;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() => isLiked = !isLiked);
    _controller.forward();
    // TODO: call your backend to save like
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: SvgIcon(
              isLiked
                  ? 'assets/activicon/like-filled.svg'
                  : 'assets/activicon/like.svg',
              color: isLiked
                  ? Colors.red
                  : const Color.fromARGB(255, 17, 17, 17),
              size: 18,
            ),
          ),
          if (widget.count.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              widget.count,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ],
      ),
    );
  }
}

class BookmarkButton extends StatefulWidget {
  const BookmarkButton({super.key});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  bool isBookmarked = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
    _controller.forward();
    // TODO: Save bookmark state to backend if needed
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleBookmark,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SvgIcon(
          isBookmarked
              ? 'assets/activicon/bookmark-filled.svg'
              : 'assets/activicon/bookmark.svg',
          color: isBookmarked
              ? const Color.fromARGB(255, 68, 68, 68)
              : const Color.fromARGB(255, 17, 17, 17),
          size: 18,
        ),
      ),
    );
  }
}
