import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zimax/src/components/svgicon.dart';
import 'package:zimax/src/services/riverpod.dart';

class Posts extends ConsumerStatefulWidget {
  const Posts({super.key});

  @override
  ConsumerState<Posts> createState() => _PostState();
}

class _PostState extends ConsumerState<Posts> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final linkController = TextEditingController();

  String postType = "text"; // text / media / link
  String? selectedCommunity;

  File? selectedImage;
  bool isUploading = false;

  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  Future<void> pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (file != null) {
      setState(() => selectedImage = File(file.path));
    }
  }

  Future<String?> uploadImage() async {
    if (selectedImage == null) return null;

    setState(() => isUploading = true);

    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final fileName =
        "posts/${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    try {
      await supabase.storage
          .from("post_media")
          .upload(fileName, selectedImage!);

      final imageUrl = supabase.storage
          .from("post_media")
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      showSnack("Upload failed: $e", isError: true);
      return null;
    } finally {
      setState(() => isUploading = false);
    }
  }

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isError ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isError ? Colors.red.shade200 : Colors.green.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_rounded : Icons.check_circle_rounded,
                color: isError ? Colors.red.shade400 : Colors.green.shade400,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final username = user!.fullname;
    final pfp = user.pfp;
    final email = user.email;
    final canPost = titleController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          'Zimax posts',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            child: TextButton(
              onPressed: canPost ? () {} : null,
              style: TextButton.styleFrom(
                backgroundColor: canPost ? Colors.black : Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Post", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _communitySelector(),
          const SizedBox(height: 20),

          _postTypeSelector(),
          const SizedBox(height: 24),

          _composerHeader('$pfp ', '$username ', '$email '),
          const SizedBox(height: 16),

          _titleField(),
          const SizedBox(height: 12),

          if (postType == "text") _bodyField(),
          if (postType == "media") _mediaPicker(),
          if (postType == "link") _urlField(),
        ],
      ),
    );
  }

  Widget _communitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SvgIcon(
            "assets/icons/post_icon.svg",
            color: const Color.fromARGB(255, 85, 85, 85),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: selectedCommunity,
              hint: Text(
                "post to...",
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              items: ["Zimax home", "Engagements", "Spaces", "Groups"]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        "@ $e",
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedCommunity = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _postTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _typeChip("text", 'assets/icons/text.svg'),
        const SizedBox(width: 10),
        _typeChip("media", 'assets/icons/media.svg'),
        const SizedBox(width: 10),
        _typeChip("link", 'assets/icons/link.svg'),
      ],
    );
  }

  Widget _typeChip(String type, String icon) {
    final isActive = postType == type;
    return GestureDetector(
      onTap: () => setState(() => postType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SvgIcon(
              icon,
              color: isActive ? Colors.white : Colors.black54,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              type[0].toUpperCase() + type.substring(1),
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _composerHeader(String pfp, String username, String email) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
            imageUrl: pfp,
            width: 40,
            height: 40,
            fit: BoxFit.cover,

            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
            Text(
              email,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w300,
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _titleField() {
    return TextField(
      controller: titleController,
      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
      cursorHeight: 20,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        hintText: 'Title',
        hintStyle: GoogleFonts.poppins(fontSize: 13),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 12.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.8),
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
        ),
      ),
    );
  }

  Widget _bodyField() {
    return TextField(
      controller: bodyController,
      maxLines: 8,
      minLines: 4,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: "What's on your mind?",
        hintStyle: GoogleFonts.poppins(fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _urlField() {
    return TextField(
      controller: linkController,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        hintText: "Paste your link",
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(Icons.link, size: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _mediaPicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),

        child: selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  selectedImage!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 38,
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Add photo",
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
