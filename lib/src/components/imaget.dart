import 'package:flutter/material.dart';


class ImageDisplay extends StatelessWidget {
  const ImageDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 130,
      child: Stack(
        children: [
          // Image 1 from the left
          Positioned(
            top: 25,
            bottom: 25,
            left: 0,
            child: Imaget(
              width: 80, 
              height: 83, 
              imagename:'assets/images/img3.png')),
          // Image 1 from the right
          Positioned(
            top: 25,
            bottom: 25,
            right: 0,
            child: Imaget(
              width: 80, 
              height: 83, 
              imagename:'assets/images/img6.png')),
          // Image 2 from the left
          Positioned(
            top: 18,
            bottom: 18,
            left: 40,
            child: Imaget(
              width: 100, 
              height: 95, 
              imagename:'assets/images/img5.png')),
          // Image 2 from the right
          Positioned(
            top: 18,
            bottom: 18,
            right: 40,
            child: Imaget(
              width: 100, 
              height: 95, 
              imagename:'assets/images/img4.png')),
          // Centered Image
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Imaget(
                width: 135, 
                height: 130, 
                imagename:'assets/images/img2.png'),
            )),
     
          
        ],
      ),
    );
  }
}

class Imaget extends StatelessWidget {
  final double width;
  final double height;
  final String imagename;

  const Imaget({super.key, required this.width, required this.height, required this.imagename});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 4,
            color: const Color.fromARGB(112, 0, 0, 0)
          )
        ],
         image: DecorationImage(
           image: AssetImage(imagename),
           fit: BoxFit.cover
         ))
    );
  }
}