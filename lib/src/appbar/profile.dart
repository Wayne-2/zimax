import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zimax/src/services/riverpod.dart';

class Profilepage extends ConsumerStatefulWidget {
  const Profilepage({super.key});

  @override
  ConsumerState<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends ConsumerState<Profilepage> {
  @override
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final username = user!.fullname;
    final status = user.status;
    final department = user.department;
    final level = user.level;
    final joinIn = user.createdAt; // DateTime
    final readable = DateFormat('d MMM yyyy').format(joinIn!);



    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bgimg1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // blur overlay
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    color: const Color.fromARGB(110, 20, 20, 20),
                  ),
                ),
              ),

              // centered logo text
              SizedBox(
                height: 150,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Text(
                        "Zimax",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // profile photo
              Positioned(
                bottom: -35,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 38,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: CachedNetworkImage(
                      imageUrl: user.pfp,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 70,
                          height: 70,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person, size: 32),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 45),

          // user info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _getStatusIcon(status), // <- added clean badge icon
                  ],
                ),

                Text(
                  user.email,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 6),

                Text(
                  "$department • $level • Joined $readable",
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      "200",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Followers",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),

                    const SizedBox(width: 20),

                    Text(
                      "180",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Following",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Icon _getStatusIcon(String status) {
  switch (status) {
    case "Student":
      return const Icon(
        Icons.school,
        size: 18,
        color: Color.fromARGB(255, 0, 0, 254),
      );
    case "Academic Staff":
      return const Icon(
        Icons.star,
        size: 18,
        color: Color.fromARGB(255, 255, 208, 0),
      );
    case "Non-Academic Staff":
      return const Icon(
        Icons.work,
        size: 18,
        color: Color.fromARGB(255, 255, 0, 0),
      );
    case "Admin":
      return const Icon(
        Icons.verified,
        size: 18,
        color: Color.fromARGB(255, 2, 145, 19),
      );
    default:
      return const Icon(Icons.person, size: 18, color: Colors.grey);
  }
}
