import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_app/controller/gallery_view.dart';
import 'package:new_app/views/camera_view.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../theme_controller.dart';
import 'how_to_use.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.brightness_6),
                  tooltip: 'Toggle Dark Mode',
                  onPressed: () {
                    Get.find<ThemeController>().toggleTheme();
                  },
                ),
              ),
              const SizedBox(height: 20),

              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GradientText(
                    'Sign2Text',
                    style: GoogleFonts.interTight(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    colors: const [Color(0xFF10C3F6), Color(0xFFFFFF00)],
                    gradientType: GradientType.radial,
                    radius: 8,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/wlc.jpg'),
              ),

              const SizedBox(height: 16),
              Text(
                'Welcome to Sign2Text\n\nBridging the communication gap with real-time hand sign translation.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16),
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const HowToUseView());
                },
                icon: const Icon(Icons.question_mark),
                label: const Text('How To Use'),
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const CameraView());
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Start Translating'),
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 14, 122, 0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const GalleryView());
                },
                icon: const Icon(Icons.image),
                label: const Text('Upload From Gallery'),
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
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
