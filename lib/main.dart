import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_app/homepage/home_widget.dart';
import 'package:new_app/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (controller) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Real-Time Hand Sign Translation',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
          themeMode: controller.themeMode,
          home: const HomeWidget(),
        );
      },
    );
  }
}
