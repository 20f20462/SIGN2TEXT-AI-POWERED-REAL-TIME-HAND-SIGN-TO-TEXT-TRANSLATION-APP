import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_app/controller/scan_controller.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translate Page'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: GetBuilder<ScanController>(
        init: ScanController(),
        builder: (controller) {
          return Stack(
            children: [
              Obx(
                () =>
                    controller.isCameraInitialized.value
                        ? CameraPreview(controller.cameraController)
                        : const Center(child: CircularProgressIndicator()),
              ),

              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Obx(
                  () => Container(
                    padding: const EdgeInsets.all(12),
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                    child: Text(
                      controller.recognizedText.value == "No hand sign detected"
                          ? controller.recognizedText.value
                          : "${controller.recognizedText.value} (${controller.confidence.value.toStringAsFixed(2)}%)",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
