import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:weather_app1/core/constants/app_env.dart';
import 'package:weather_app1/core/logger/app_logger.dart';
import 'package:weather_app1/core/network/app_api_loading_controller.dart';
import 'package:weather_app1/core/network/app_http_extras.dart';
import 'package:weather_app1/core/session/session_controller.dart';

/// Dio client for remote APIs: timeouts, headers, session token, loading overlay,
/// and structured logging via [AppLogger].
class AppHttpClient {
  AppHttpClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.openWeatherBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: <String, dynamic>{
          Headers.acceptHeader: 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll(<Interceptor>[
      _LoadingInterceptor(),
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          if (Get.isRegistered<SessionController>()) {
            final String? token =
                Get.find<SessionController>().accessToken.value;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          AppLogger.logDioRequest(options);
          handler.next(options);
        },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
          AppLogger.logDioResponse(response);
          handler.next(response);
        },
        onError: (DioException err, ErrorInterceptorHandler handler) {
          AppLogger.logDioError(err);
          handler.next(err);
        },
      ),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;
}

final class _LoadingInterceptor extends Interceptor {
  bool _quiet(RequestOptions o) =>
      o.extra[AppHttpExtras.quietNetwork] == true;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!_quiet(options) && Get.isRegistered<AppApiLoadingController>()) {
      Get.find<AppApiLoadingController>().begin();
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _end(response.requestOptions);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _end(err.requestOptions);
    handler.next(err);
  }

  void _end(RequestOptions options) {
    if (_quiet(options)) {
      return;
    }
    if (Get.isRegistered<AppApiLoadingController>()) {
      Get.find<AppApiLoadingController>().end();
    }
  }
}
