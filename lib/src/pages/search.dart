import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zimax/src/components/carousel.dart';
import 'package:zimax/src/services/riverpod.dart';

class Search extends ConsumerStatefulWidget {
  const Search({super.key});

  @override
  ConsumerState<Search> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> {
  final supabase = Supabase.instance.client;
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> results = [];
  bool loading = false;

  Future<void> search(String query) async {
    if (query.isEmpty) {
      setState(() => results = []);
      return;
    }

    setState(() => loading = true);

    try {
      final response = await supabase
          .from('media_posts')
          .select()
          .or(
            'title.ilike.%$query%,content.ilike.%$query%',
          )
          .order('created_at', ascending: false);

      setState(() {
        results = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Search error: $e");
      setState(() => results = []);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final hasTyped = searchController.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:Container(
         padding: const EdgeInsets.symmetric(horizontal: 10.0),
         height: 40,
         decoration: BoxDecoration(
           color: const Color.fromARGB(255, 235, 235, 235),
           borderRadius: BorderRadius.circular(50),
         ),
         child: TextField(
           controller: searchController,
           decoration: InputDecoration(
             border: InputBorder.none,
             hintText: 'Search zimax',
             // contentPadding: EdgeInsets.zero,
             hintStyle: GoogleFonts.poppins(
               fontSize: 13,
               fontWeight: FontWeight.w500,
             ),
             prefixIcon: Icon(Icons.manage_search_sharp),
           ),
           onChanged: (value) {
            search(value);
           },
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
                child: const Icon(Icons.person, color: Colors.grey, size: 16),
              ),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
         
          // const SizedBox(height: 16),
      
          // Results
          // UI States
            if (!hasTyped)
      // BEFORE SEARCH
      Expanded(
        child: Column(
          children: [
            GradientCarousel(
              images: [
                "https://picsum.photos/400/250",
                "https://picsum.photos/401/250",
                "https://picsum.photos/402/250",
              ],
              titles: [
                "Welcome to Zimax",
                "Discover Trending Posts",
                "Engage With Your Community",
              ],
            ),
          ],
        )
      )
            else if (loading)
      // LOADING
      const Expanded(
        child: Center(child: CircularProgressIndicator()),
      )
            else if (results.isEmpty)
      // NO RESULTS
      const Expanded(
        child: Center(
          child: Text(
            "No results found",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      )
            else
      // SHOW RESULTS
      Expanded(
        child: ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final post = results[index];
            return ListTile(
              title: Text(post['title'] ?? ""),
              subtitle: Text(post['content'] ?? ""),
            );
          },
        ),
      ),
        ],
      ),
    );
  }
}

