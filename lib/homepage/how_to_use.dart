import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HowToUseView extends StatelessWidget {
  const HowToUseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How To Use"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '''
1. Allow camera permissions.
2. Position your hand in front of the camera.
3. The app will detect and translate the sign into text.
4. Use good lighting and a steady background for better accuracy.
''',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
