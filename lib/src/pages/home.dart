import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zimax/src/components/post_card.dart';
import 'package:zimax/src/components/videotiles.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Icon(Icons.menu_open_outlined),
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
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage("https://i.pravatar.cc/300"),
              ),
            ),
          ),
          SizedBox(width: 15),
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
                    "https://picsum.photos/403/600",
                    "https://picsum.photos/403/600",
                    "https://picsum.photos/403/600",
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
