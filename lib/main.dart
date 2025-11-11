import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Zimax()));
}

class Zimax extends StatelessWidget {
  const Zimax({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bgimg1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 15.0,
              sigmaY: 15.0, 
            ),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(6, 255, 255, 255), 
                    const Color.fromARGB(118, 0, 0, 0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Text(
                  "Frosted Glass Box",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),)
        ],
      ),
    );
  }
}
