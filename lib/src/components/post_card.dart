import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zimax/src/components/svgicon.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String handle;
  final String tweet;
  final String? imageUrl;

  const PostCard({
    super.key,
    required this.username,
    required this.handle,
    required this.tweet,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white12),
        ),
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
                       imageUrl: "https://i.pravatar.cc/300",
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
                              Text("$username ",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),
                              ),
                              Icon(Icons.label, size: 12,)
                            ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text( "Computer Sci",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300, fontSize: 11, color: Colors.black),
                              ),
                              SizedBox(width: 4,),
                              Icon(Icons.circle, size: 3,),
                              SizedBox(width: 4,),
                              Text('2m ago',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300, fontSize: 11, color: Colors.black),
                              ),
                            ],
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(Icons.more_horiz, size: 18,)
              ],
            ),
      
            const SizedBox(height: 4),

            if (imageUrl != null) ...[
              const SizedBox(height: 10),
            
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
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
              tweet,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400),
            ),
      
            const SizedBox(height: 10),
      
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _ActivIcon('assets/activicon/repost.svg', "34"),
                _ActivIcon('assets/activicon/like.svg', "12"),
                _ActivIcon('assets/activicon/comment.svg', "230"),
                _ActivIcon('assets/activicon/activity.svg', "120k"),
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

class _ActivIcon extends StatelessWidget {
  final String icon;
  final String count;
  const _ActivIcon(this.icon, this.count);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgIcon(icon, color: const Color.fromARGB(255, 45, 45, 45), size: 14,),
        const SizedBox(width: 4),
        if (count.isNotEmpty)
          Text(count, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
