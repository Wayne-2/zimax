import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/components/carousel.dart';

class Placeholdersearchpage extends StatefulWidget {
  const Placeholdersearchpage({super.key});

  @override
  State<Placeholdersearchpage> createState() => _PlaceholdersearchpageState();
}

class _PlaceholdersearchpageState extends State<Placeholdersearchpage> {
  List recent = [];

  Future<List<Map<String, dynamic>>> fetchRecentSearches() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final response = await supabase
        .from('recent_searches')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  void initState() {
    super.initState();
    loadRecent();
  }

  Future<void> loadRecent() async {
    recent = await fetchRecentSearches();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
          child: Row(
            children: [
              Text(
                'Recent Search',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recent.length,
              itemBuilder: (context, index) {
                final item = recent[index]['query'];
                if (recent.isEmpty) {
                  Text('No recent search',style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),);
                }
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 205, 205, 205),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
