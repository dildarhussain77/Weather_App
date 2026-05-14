import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app1/core/network/app_api_loading_controller.dart';

/// Full-screen loading barrier when [AppApiLoadingController.inFlight] &gt; 0.
class AppApiLoadingOverlay extends StatelessWidget {
  const AppApiLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AppApiLoadingController>()) {
      return const SizedBox.shrink();
    }
    final AppApiLoadingController c = Get.find<AppApiLoadingController>();
    return Obx(() {
      if (c.inFlight.value <= 0) {
        return const SizedBox.shrink();
      }
      return Positioned.fill(
        child: AbsorbPointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    });
  }
}
