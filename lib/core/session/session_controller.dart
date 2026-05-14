import 'package:get/get.dart';

/// Session / auth state (token hook for remote [AppHttpClient] interceptors).
class SessionController extends GetxController {
  final RxnString accessToken = RxnString();

  void setToken(String? token) => accessToken.value = token;

  void clearSession() => accessToken.value = null;
}
