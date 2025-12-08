import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zimax/src/components/svgicon.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String department;
  final String status;
  final String pfp;
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
    required this.postcontent,
    required this.repost,
    required this.like,
    required this.comment,
    required this.poll,
    this.imageUrl,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
   final readableDate = DateFormat("d MMM yyyy").format(createdAt);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Expanded(
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
                        imageUrl: pfp,
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
                              "$username ",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildStatusIcon(status),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              department,
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
                Icon(Icons.more_horiz, size: 18),
              ],
            ),

            const SizedBox(height: 4),

            if (imageUrl != null) ...[
              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  height: 300,
                  width: double.infinity,
                  imageUrl: imageUrl!,
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
              postcontent,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActivIcon('assets/activicon/repost.svg', repost),
                _ActivIcon('assets/activicon/like.svg', like),
                _ActivIcon('assets/activicon/comment.svg', comment),
                _ActivIcon('assets/activicon/activity.svg', poll),
                _ActivIcon('assets/activicon/bookmark.svg', ""),
                _ActivIcon('assets/activicon/share.svg', ""),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
  Icon _buildStatusIcon(String status) {
    switch (status) {
      case "Student":
        return const Icon(Icons.school, size: 18, color: Color.fromARGB(255, 33, 89, 243));
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

class _ActivIcon extends StatelessWidget {
  final String icon;
  final String count;
  const _ActivIcon(this.icon, this.count);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgIcon(icon, color: const Color.fromARGB(255, 45, 45, 45), size: 14),
        const SizedBox(width: 4),
        if (count.isNotEmpty)
          Text(count, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
