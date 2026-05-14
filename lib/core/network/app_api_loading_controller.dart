import 'package:get/get.dart';

/// Drives the global API loading overlay ([AppApiLoadingOverlay]) from
/// [AppHttpClient] interceptors.
final class AppApiLoadingController extends GetxController {
  final RxInt inFlight = 0.obs;

  void begin() {
    inFlight.value++;
  }

  void end() {
    if (inFlight.value > 0) {
      inFlight.value--;
    }
  }
}
