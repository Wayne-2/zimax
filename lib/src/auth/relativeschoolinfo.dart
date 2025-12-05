import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zimax/src/auth/uploadpfp.dart';
import 'package:zimax/src/components/inputfield.dart';

class Relativeschoolinfo extends StatelessWidget {
  const Relativeschoolinfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.arrow_back, size: 13, color:Colors.white)),
                      SizedBox(width: 5,),
                    Text(
                      "back",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 18, 18, 18),
                      ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 60,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Create Account",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 35, 35, 35),
                      ),
                    ),
                    
                  ],
                ),
              SizedBox(height: 10,),
              Text(
                'Relative School Details',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10,),
              Text(
                "The follow information are very important and should be filled carefully.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromARGB(255, 90, 90, 90),
                ),
              ),
              SizedBox(height: 20),
              InputField(obscureText: false, hintText: 'Department'),
              SizedBox(height: 10),
              Dropdown(hint: 'Level', items: ["100 level", "200 level", "300 level", "400 level", "500 level", "N/A"], ),
              SizedBox(height: 10),
              InputField(obscureText: false, hintText: 'ID/Reg Number'),
              SizedBox(height: 10),
              Dropdown(hint: 'Student', items: ["Student", "Academic Staff", "Non-Academic Staff", "Admin"], ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Uploadpfp()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Continue',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
