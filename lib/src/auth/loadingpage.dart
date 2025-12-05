import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:zimax/src/components/navbar.dart';

class Loadingpage extends StatefulWidget {
  const Loadingpage({super.key});

  @override
  State<Loadingpage> createState() => _LoadingpageState();
}

class _LoadingpageState extends State<Loadingpage> {
  @override
  void initState() {
    super.initState();

    // Wait 5 seconds then navigate
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavBar()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 60),
        width: double.infinity,
        height: MediaQuery.of(context).size.height*1,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/logodark.png')
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // App name
                  Text(
                    "Zimax",
                    style: GoogleFonts.poppins(
                      fontSize: 29,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
        
          
        
             Column(
               children: [
                 LoadingAnimationWidget.stretchedDots(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    size: 45,
                  ),
                 
                  const SizedBox(height: 15),
                  Text(
                    "Getting ready",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color:Colors.black,
                    ),
                  ),
               ],
             ),
            ],
          ),
        ),
      ),
    );
  }
}
