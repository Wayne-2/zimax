import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zimax/src/components/post_card.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedTab = 0; // 0 = For You, 1 = Following

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Icon(Icons.menu_open_outlined),
        automaticallyImplyActions: false,
        backgroundColor: Colors.white,
        title: Text('Zimax', style:GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, ))
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return PostCard(
            username: "John Doe",
            handle: "@johndoe",
            tweet:
                "This is a sample tweet UI design built entirely in Flutter. Looks clean!",
            imageUrl: index % 2 == 0
                ? "https://picsum.photos/400/300"
                : null,
          );
        },
      ),
    );
  }
}



