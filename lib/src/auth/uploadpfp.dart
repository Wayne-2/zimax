import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Uploadpfp extends StatefulWidget {
  const Uploadpfp({super.key});

  @override
  State<Uploadpfp> createState() => _UploadpfpState();
}

class _UploadpfpState extends State<Uploadpfp> {
  File? _selectedImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  // Pick Image
  Future<void> pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (file != null) {
      setState(() => _selectedImage = File(file.path));
    }
  }

  // Upload + update DB
  Future<void> uploadImage() async {
    if (_selectedImage == null) {
      _showAlert("No Image", "Please select an image first.");
      return;
    }

    setState(() => _isUploading = true);

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final fileName =
        "profile/${user.id}/${DateTime.now().millisecondsSinceEpoch}.png";

    try {
      // Upload file
      await supabase.storage.from("avatars").upload(
            fileName,
            _selectedImage!,
          );

      // Get public URL
      final imageUrl =
          supabase.storage.from("avatars").getPublicUrl(fileName);

      // Update profile table
      await supabase.from("user_profile").update({
        "profile_image_url": imageUrl,
      }).eq("id", user.id);

      _showAlert("Success", "Profile photo updated successfully!");

    } catch (error) {
      _showAlert("Error", "Failed to upload image: $error");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.black,
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Back",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              Center(
                child: Text(
                  "Update Profile Photo",
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 40),

              // Profile Photo
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 135,
                        height: 135,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: _selectedImage == null
                            ? Image.asset(
                                "assets/nopfp.png",
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                _selectedImage!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Theme.of(context)
                          .dividerColor
                          .withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    "Tap to edit profile photo",
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: _isUploading ? null : uploadImage,
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Center(
                    child: _isUploading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : Text(
                            'Finish',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
