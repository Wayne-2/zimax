import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zimax/src/models/story.dart';

class StoryPage extends StatefulWidget {
  final List<StoryItem> stories;
  final int initialIndex;

  const StoryPage({super.key, required this.stories, this.initialIndex = 0});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int currentIndex = 0;
  final TextEditingController _replyController = TextEditingController();
  bool showReplyField = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        nextStory();
      }
    });

    _progressController.forward();
  }

  void _startProgress() {
    _progressController.reset();
    _progressController.forward();
  }

  void nextStory() {
    if (currentIndex < widget.stories.length - 1) {
      setState(() => currentIndex++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startProgress();
      setState(() => showReplyField = false);
    } else {
      Navigator.pop(context);
    }
  }

  void previousStory() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startProgress();
      setState(() => showReplyField = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final story = widget.stories[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Stories PageView
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.stories.length,
          itemBuilder: (_, index) {
            final s = widget.stories[index];
          
            if (s.isText || (s.imageUrl == null && s.text != null)) {
              // Text-only story
              return Container(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      s.text ?? '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            } else if (s.imageUrl != null) {
              // Image or image + text story
              return Stack(
                children: [
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: s.imageUrl!,
                      width: double.infinity,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade700,
                        highlightColor: Colors.grey.shade500,
                        child: Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.grey,
                        ),
                      ),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                  if (s.text != null)
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          s.text!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            } else {
              // Fallback empty container if both image and text are null
              return Container(color: Colors.black);
            }
          },

          ),

          // Top progress bars + user info + back button
          Positioned(
            top: 15,
            left: 10,
            right: 10,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (_, __) {
                    return Row(
                      children: widget.stories
                          .asMap()
                          .map((i, e) {
                            return MapEntry(
                              i,
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: LinearProgressIndicator(
                                    value: i == currentIndex
                                        ? _progressController.value
                                        : (i < currentIndex ? 1 : 0),
                                    backgroundColor: Colors.white24,
                                    color: Colors.white,
                                    minHeight: 2,
                                  ),
                                ),
                              ),
                            );
                          })
                          .values
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.stories[currentIndex].avatar ?? '',
                      ),
                      radius: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.stories[currentIndex].name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tap to navigate + swipe up
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                final width = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < width / 2) {
                  previousStory();
                } else {
                  nextStory();
                }
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! < -150) {
                  setState(() => showReplyField = true);
                }
              },
            ),
          ),

          // Reply text field
          if (showReplyField)
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: TextField(
                        controller: _replyController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Send reply...",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (val) {
                          if (val.isNotEmpty) _replyController.clear();
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_replyController.text.isNotEmpty) _replyController.clear();
                    },
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
