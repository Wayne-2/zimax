import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                     Container(
                       width:33,
                       height:33,
                       decoration:BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                         image: DecorationImage(
                           image: NetworkImage(
                                   "https://i.pravatar.cc/300",
                                 ),))),
                      
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
                child: Image.network(imageUrl!),
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
            )
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
