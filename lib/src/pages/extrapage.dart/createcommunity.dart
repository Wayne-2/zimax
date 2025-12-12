import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreateCommunity extends StatefulWidget {
  const CreateCommunity({super.key});

  @override
  State<CreateCommunity> createState() => _CreateCommunityState();
}

class _CreateCommunityState extends State<CreateCommunity> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isPrivate = false;
  File? _avatarImage;

  /// Pick an image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  void _createCommunity() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community name cannot be empty')),
      );
      return;
    }

    // TODO: Send data to backend or Supabase, including _avatarImage if selected
    print(
        "Creating Community: $name, Description: $description, Private: $isPrivate, Avatar: ${_avatarImage?.path}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Community created successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Create Community',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Photo Section
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    _avatarImage != null ? FileImage(_avatarImage!) : null,
                child: _avatarImage == null
                    ? const Icon(
                        Icons.camera_alt_outlined,
                        size: 30,
                        color: Colors.white70,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Community Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Community Name',
                labelStyle: GoogleFonts.poppins(fontSize: 14),
                hintText: 'Enter community name',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: GoogleFonts.poppins(fontSize: 14),
                hintText: 'Tell members what this community is about',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Privacy Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Private Community',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                Switch(
                  value: isPrivate,
                  onChanged: (value) {
                    setState(() {
                      isPrivate = value;
                    });
                  },
                  activeColor: Colors.black,
                ),
              ],
            ),

            const Spacer(),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _createCommunity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Create Community',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
