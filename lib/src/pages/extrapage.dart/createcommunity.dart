import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateCommunity extends StatefulWidget {
  const CreateCommunity({super.key});

  @override
  State<CreateCommunity> createState() => _CreateCommunityState();
}

class _CreateCommunityState extends State<CreateCommunity> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _customLink = TextEditingController();
  String? selectedCategory;
  String region = "US East";
  bool isPrivate = false;
  bool ageRestricted = false;
  File? avatar;
  File? banner;

  final categories = [
    "Technology",
    "Gaming",
    "Education",
    "Programming",
    "Entertainment",
    "Fashion",
    "Music",
    "Business",
    "Sports",
    "Crypto",
  ];

  Future<void> pickAvatar() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file != null) setState(() => avatar = File(file.path));
  }

  Future<void> pickBanner() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file != null) setState(() => banner = File(file.path));
  }

  void create() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name cannot be empty")));
      return;
    }

    print("""
Creating community:
Name: ${_name.text}
Description: ${_description.text}
Link: ${_customLink.text}
Category: $selectedCategory
Region: $region
Private: $isPrivate
Age Restricted: $ageRestricted
Avatar: ${avatar?.path}
Banner: ${banner?.path}
""");

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text(
          "Create Community",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(child: _form()),
          _createButton(),
        ],
      ),
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bannerPicker(),
          const SizedBox(height: 20),
          _avatarPicker(),
          const SizedBox(height: 20),
          _textField("Community Name", "Enter name", _name),
          const SizedBox(height: 16),
          _textField(
            "Description",
            "Tell people what this community is about",
            _description,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _sectionTitle("Category"),
          _categoryDropdown(),
          const SizedBox(height: 16),
          _sectionTitle("Custom Community Link"),
          _textField("zimax.app//link/", "your-custom-link", _customLink),
          const SizedBox(height: 16),
          _toggles(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // BANNER PICKER (Discord style top banner)
  // ----------------------------------------------------------
  Widget _bannerPicker() {
    return GestureDetector(
      onTap: pickBanner,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          image: banner != null
              ? DecorationImage(image: FileImage(banner!), fit: BoxFit.cover)
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: banner == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_outlined,
                      size: 36,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Add Banner Image",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _avatarPicker() {
    return Center(
      child: GestureDetector(
        onTap: pickAvatar,
        child: CircleAvatar(
          radius: 44,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: avatar != null ? FileImage(avatar!) : null,
          child: avatar == null
              ? const Icon(
                  Icons.camera_alt_outlined,
                  size: 32,
                  color: Colors.white70,
                )
              : null,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TEXT FIELD
  // ----------------------------------------------------------
  Widget _textField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // CATEGORY DROPDOWN
  // ----------------------------------------------------------
  Widget _categoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,

          hint: Text(
            "Select a category",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          items: categories
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, style: GoogleFonts.poppins(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => selectedCategory = value),
        ),
      ),
    );
  }

  Widget _toggles() {
    return Column(
      children: [
        SwitchListTile(
          title: Text(
            "Private Community",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          value: isPrivate,
          activeColor: Colors.black,
          onChanged: (v) => setState(() => isPrivate = v),
        ),
        SwitchListTile(
          title: Text(
            "Age Restricted (18+)",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          value: ageRestricted,
          activeColor: Colors.black,
          onChanged: (v) => setState(() => ageRestricted = v),
        ),
      ],
    );
  }

  Widget _createButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: create,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Create Community",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }
}
