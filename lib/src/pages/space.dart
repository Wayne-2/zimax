import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zimax/src/pages/extrapage.dart/community.dart';
import 'package:zimax/src/pages/extrapage.dart/createcommunity.dart';
import 'package:zimax/src/services/riverpod.dart';

class Space extends ConsumerStatefulWidget {
  const Space({super.key});

  @override
  ConsumerState<Space> createState() => _SpaceState();
}

class _SpaceState extends ConsumerState<Space> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);

    // Example communities
    final communities = List.generate(4, (index) => index);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text(
          'Zimax Space',
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 80,
            ), // leave space for bottom button
            child: Column(
              children: [
                const SizedBox(height: 10),
                _searchBar(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: communities.length,
                    itemBuilder: (context, index) {
                      return _communityCard(communities[index]);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Create Community Button at the bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateCommunity()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      "Create Community",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      height: 40,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 226, 226, 226),
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search Zimax Space',
          hintStyle: GoogleFonts.poppins(fontSize: 13),
          prefixIcon: const Icon(Icons.manage_search_sharp),
        ),
      ),
    ),
  );

  Widget _communityCard(int index) {
    final bool isJoined = index % 2 == 0; // example condition
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image container (square)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://i.pravatar.cc/150?img=${index + 10}",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Community #$index",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${50 + index * 5} members · ${isJoined ? "Public" : "Private"}",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Community()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isJoined
                          ? Colors
                                .grey
                                .shade800 
                          : Colors.black, 
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      isJoined ? "Joined" : "Join",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
