import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(children: [
          //logo
          Padding(
            padding: const EdgeInsets.only(
                left: 80, right: 80, bottom: 40, top: 160),
            child: Image.asset('lib/images/avocato.png'),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Please select your groceries",
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerif(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Text(
            "Don't forget the tip!",
            style: TextStyle(color: Colors.grey[600]),
          ),

          const SizedBox(height: 24),

          const Spacer(),

          // get started button
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const HomePage();
                },
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color.fromARGB(255, 112, 91, 222),
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(
                  color: Colors.white,
                  // fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const Spacer(),
        ]),
      ));
}
