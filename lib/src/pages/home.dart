import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zimax/src/components/appdrawer.dart';
import 'package:zimax/src/components/post_card.dart';
// import 'package:zimax/src/components/svgicon.dart';
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
    final user = ref.watch(userProfileProvider);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Icon(Icons.density_medium_rounded)),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          'Zimax',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: user!.pfp,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
          
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
          const SizedBox(width: 15),
        ],

      ),
      backgroundColor: Colors.white,

      body: ListView.builder(
        itemCount: 50, // Example count
        itemBuilder: (context, index) {
          final postCard = PostCard(
            username: "John Doe",
            handle: "@johndoe",
            tweet:
                "This is a sample tweet UI design built entirely in Flutter. Looks clean!",
            imageUrl: index % 2 == 0 ? "https://picsum.photos/400/300" : null,
          );

          // Add VideoTileRow after every 7th post
          if ((index + 1) % 6 == 0) {
            return Column(
              children: [
                postCard,
                SizedBox(height: 10),
                VideoTileRow(
                  videoThumbnails: [
                    "https://picsum.photos/400/600",
                    "https://picsum.photos/401/600",
                    "https://picsum.photos/402/600",
                    "https://picsum.photos/403/600",
                    "https://picsum.photos/404/600",
                    "https://picsum.photos/405/600",
                    "https://picsum.photos/406/600",
                  ],
                ),
                SizedBox(height: 10),
              ],
            );
          }

          return postCard;
        },
      ),
    );
  }
}
