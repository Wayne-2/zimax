import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zimax/src/components/appdrawer.dart';
import 'package:zimax/src/components/post_card.dart';
import 'package:zimax/src/components/videotiles.dart';
import 'package:zimax/src/services/riverpod.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(zimaxHomePostsProvider);
    final user = ref.watch(userProfileProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text(
          'Zimax',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        actions: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: user!.pfp,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),

      backgroundColor: Colors.white,

      body: postsAsync.when(
        loading:  () => ListView.builder(
                  itemCount: 4,
                  itemBuilder: (_, __) => postShimmer(),
                ),
        error: (err, _) => Center(
          child: Text("Error: $err", style: GoogleFonts.poppins(fontSize: 14)),
        ),

        data: (posts) {
          if (posts.isEmpty) {
            return Center(
              child: Text(
                "No posts yet",
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              final postCard = PostCard(
                username: post.username,
                pfp: post.pfp,
                department: post.department,
                status: post.status,
                imageUrl: post.mediaUrl,
                postcontent: post.content ?? '',
                like: post.likes.toString(),
                comment: post.comments.toString(),
                poll: post.polls.toString(),
                repost: post.reposts.toString(),
                createdAt: post.createdAt,
              );

              // Insert VideoRow after every 6 posts
              if ((index + 1) % 6 == 0) {
                return Column(
                  children: [
                    postCard,
                    const SizedBox(height: 10),
                    VideoTileRow(
                      videoThumbnails: [
                        "https://picsum.photos/400/600",
                        "https://picsum.photos/401/600",
                        "https://picsum.photos/402/600",
                      ],
                    ),
                  ],
                );
              }

              return postCard;
            },
          );
        },
      ),
    );
  }
}
Widget postShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ------------------ HEADER ------------------
          Row(
            children: [
              // Profile picture shimmer
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
              const SizedBox(width: 10),

              // Name + department + date
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 160,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ------------------ IMAGE ------------------
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.white,
          ),

          const SizedBox(height: 16),

          // ------------------ TEXT CONTENT ------------------
          Container(
            width: double.infinity,
            height: 12,
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 12,
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          Container(
            width: 200,
            height: 12,
            color: Colors.white,
          ),

          const SizedBox(height: 16),

          // ------------------ ACTION ICONS ------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _iconShimmer(),
              _iconShimmer(),
              _iconShimmer(),
              _iconShimmer(),
              _iconShimmer(),
              _iconShimmer(),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _iconShimmer() {
  return Container(
    width: 24,
    height: 24,
    color: Colors.white,
  );
}

// Icon _getStatusIcon(String status) {
//   switch (status) {
//     case "Student":
//       return const Icon(Icons.school, size: 18, color: Color.fromARGB(255, 0, 0, 254));
//     case "Academic Staff":
//       return const Icon(Icons.star, size: 18, color: Color.fromARGB(255, 255, 208, 0));
//     case "Non-Academic Staff":
//       return const Icon(Icons.work, size: 18, color: Color.fromARGB(255, 255, 0, 0));
//     case "Admin":
//       return const Icon(Icons.verified, size: 18, color: Color.fromARGB(255, 2, 145, 19));
//     default:
//       return const Icon(Icons.person, size: 18, color: Colors.grey);
//   }
// }
