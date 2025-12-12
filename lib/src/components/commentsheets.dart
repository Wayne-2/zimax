import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentSheet extends StatefulWidget {
  final String postId;
  final String userId;
  final String pfp;
  final String username;

  const CommentSheet({
    super.key,
    required this.postId,
    required this.userId,
    required this.pfp,
    required this.username,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final supabase = Supabase.instance.client;
  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> comments = [];
  bool loading = true;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    fetchComments();
    subscribeRealtime();
  }

  /// Fetch comments from Supabase
  Future<void> fetchComments() async {
    final data = await supabase
        .from('comment')
        .select('comment, created_at, commenter_name, profile_image_url')
        .eq('post_id', widget.postId)
        .order('created_at', ascending: true);

    setState(() {
      comments = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  /// Subscribe to realtime comments
  void subscribeRealtime() {
    supabase
        .channel('post_${widget.postId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'comment',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'post_id',
            value: widget.postId,
          ),
          callback: (payload) {
            fetchComments(); // refetch on new comment
          },
        )
        .subscribe();
  }

  Future<void> sendComment() async {
    final text = controller.text.trim();
    if (text.isEmpty || sending) return;

    setState(() => sending = true);

    try {
      final user = supabase.auth.currentUser!;
      final userId = user.id;

      await supabase.from('comment').insert({
        'post_id': widget.postId,
        'user_id': userId,
        'comment': text,
        'commenter_name': widget.username,
        'profile_image_url': widget.pfp,
      });

      controller.clear();
      await fetchComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      initialChildSize: 0.65,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),

              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      "Comments",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: loading
                    ? ListView.builder(
                        itemCount: 6,
                        itemBuilder: (_, __) => commentShimmer(),
                      )
                    : comments.isEmpty
                    ? Center(
                        child: Text(
                          "No comments yet",
                          style: GoogleFonts.poppins(),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: comments.length,
                        itemBuilder: (_, i) {
                          final c = comments[i];

                          final name = c['commenter_name'] ?? "Unknown";
                          final pfp =
                              c['profile_image_url'] ??
                              'https://kldaeoljhumowuegwjyq.supabase.co/storage/v1/object/public/avatar/profile/aaa466ec-c0c3-48f6-9f30-e6110fbf4e4d/nopfp.png';
                          final text = c['comment'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(pfp),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        text,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(widget.pfp),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            hintStyle: GoogleFonts.poppins(fontSize: 14),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: sending ? null : () async => await sendComment(),
                        child: CircleAvatar(
                          backgroundColor: sending ? Colors.grey : Colors.black,
                          child: sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_upward_rounded,
                                  color: Colors.white,
                                  size: 18,
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
      },
    );
  }
}

Widget commentShimmer() {
  return Padding(
    padding: const EdgeInsets.all(18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: const CircleAvatar(radius: 18, backgroundColor: Colors.white),
        ),

        const SizedBox(width: 10),

        // Text shimmer
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name shimmer bar
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Comment line 1
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Comment line 2 (shorter)
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 14,
                  width:
                      MediaQueryData.fromWindow(
                        WidgetsBinding.instance.window,
                      ).size.width *
                      0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
