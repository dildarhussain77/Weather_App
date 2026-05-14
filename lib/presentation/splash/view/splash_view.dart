import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app1/routes/app_routes.dart';

/// Placeholder splash (extend with branding / auth checks later).
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Get.offNamed(AppRoutes.home),
          child: const Text('Continue to Home'),
        ),
      ),
    );
  }
}
