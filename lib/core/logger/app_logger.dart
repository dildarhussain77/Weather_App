import 'dart:convert';
import 'package:dio/dio.dart';

/// Central logging helper with beautiful borders and icons
abstract final class AppLogger {
  static const Set<String> _sensitiveHeaderKeys = <String>{
    'authorization',
    'cookie',
    'set-cookie',
  };

  static const Set<String> _sensitiveQueryKeys = <String>{
    'appid',
    'apikey',
    'api_key',
    'token',
    'password',
  };

  // Border characters and icons
  static const String _horizontalLine = '─';
  static const String _verticalLine = '│';
  static const String _topLeft = '┌';
  static const String _topRight = '┐';
  static const String _bottomLeft = '└';
  static const String _bottomRight = '┘';
  static const String _cross = '├';
  static const String _leftT = '├';
  static const String _rightT = '┤';

  static void d(String message, [Object? err, StackTrace? stack]) {
    // ignore: avoid_print
    print('[D] $message ${err ?? ''}');
    if (stack != null) {
      // ignore: avoid_print
      print(stack);
    }
  }

  static void error(String message, [Object? err, StackTrace? stack]) {
    // ignore: avoid_print
    print('[E] $message ${err ?? ''}');
    if (stack != null) {
      // ignore: avoid_print
      print(stack);
    }
  }

  /// Pretty-prints JSON-like values for logs.
  static String formatData(dynamic data) {
    if (data == null) {
      return 'null';
    }
    try {
      if (data is Map || data is List) {
        const JsonEncoder enc = JsonEncoder.withIndent('  ');
        return enc.convert(data);
      }
      if (data is FormData) {
        return data.toString();
      }
      return data.toString();
    } catch (e) {
      return '${data.runtimeType} (encode error: $e)';
    }
  }

  static Map<String, dynamic> _redactHeaders(Map<String, dynamic> raw) {
    final Map<String, dynamic> out = <String, dynamic>{};
    raw.forEach((String k, dynamic v) {
      final String lower = k.toLowerCase();
      if (_sensitiveHeaderKeys.contains(lower)) {
        out[k] = '***';
      } else {
        out[k] = v;
      }
    });
    return out;
  }

  static Map<String, dynamic> _redactQuery(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }
    final Map<String, dynamic> out = <String, dynamic>{};
    raw.forEach((String k, dynamic v) {
      if (_sensitiveQueryKeys.contains(k.toLowerCase())) {
        out[k] = '***';
      } else {
        out[k] = v;
      }
    });
    return out;
  }

  static void _printBorderedBox({
    required String title,
    required String icon,
    List<String>? lines,
    String? content,
    String? status,
    bool isError = false,
  }) {
    final StringBuffer box = StringBuffer();
    final String borderColor = isError ? '\x1B[31m' : '\x1B[36m';
    final String resetColor = '\x1B[0m';
    final String titleColor = isError ? '\x1B[31m' : '\x1B[32m';

    // Top border
    box.writeln('$borderColor$_topLeft$_horizontalLine$_horizontalLine '
        '$icon $_horizontalLine$_horizontalLine $title '
        '${status != null ? "($status)" : ""} '
        '${_horizontalLine * 40}$_topRight$resetColor');

    if (lines != null) {
      for (int i = 0; i < lines.length; i++) {
        final String line = lines[i];
        final bool isLast = i == lines.length - 1;
        final String prefix = isLast ? _bottomLeft : _leftT;

        // Split long lines for better readability
        final List<String> wrappedLines = _wrapText(line, 100);
        for (int j = 0; j < wrappedLines.length; j++) {
          final String wrappedLine = wrappedLines[j];
          final String linePrefix = (j == 0) ? prefix : _verticalLine;
          box.writeln('$borderColor$linePrefix $resetColor$wrappedLine${borderColor} $_rightT$resetColor');
        }
      }
    }

    if (content != null) {
      final List<String> wrappedContent = _wrapText(content, 100);
      for (int i = 0; i < wrappedContent.length; i++) {
        final String line = wrappedContent[i];
        final bool isLast = i == wrappedContent.length - 1;
        final String prefix = isLast ? _bottomLeft : _leftT;
        box.writeln('$borderColor$prefix $resetColor$line${borderColor} $_rightT$resetColor');
      }
    }

    // If no lines or content, just close the box
    if ((lines == null || lines.isEmpty) && content == null) {
      box.writeln('$borderColor$_bottomLeft$_horizontalLine * 60$_bottomRight$resetColor');
    }

    print(box.toString());
  }

  static List<String> _wrapText(String text, int maxLength) {
    if (text.length <= maxLength) return [text];

    final List<String> lines = [];
    String remaining = text;

    while (remaining.isNotEmpty) {
      if (remaining.length <= maxLength) {
        lines.add(remaining);
        break;
      }

      int splitIndex = remaining.lastIndexOf(' ', maxLength);
      if (splitIndex == -1) splitIndex = maxLength;

      lines.add(remaining.substring(0, splitIndex));
      remaining = remaining.substring(splitIndex).trimLeft();
    }

    return lines;
  }

  static void logDioRequest(RequestOptions options) {
    final StringBuffer content = StringBuffer();

    content.writeln('┌─ METHOD: ${options.method}');
    content.writeln('├─ URL: ${options.uri}');

    // Headers
    final headers = _redactHeaders(Map<String, dynamic>.from(options.headers));
    content.writeln('├─ HEADERS:');
    headers.forEach((key, value) {
      content.writeln('│  • $key: $value');
    });

    // Query Parameters
    final queryParams = _redactQuery(options.queryParameters);
    if (queryParams.isNotEmpty) {
      content.writeln('├─ QUERY PARAMETERS:');
      queryParams.forEach((key, value) {
        content.writeln('│  • $key: $value');
      });
    }

    // Request Data/Payload
    if (options.data != null) {
      content.writeln('├─ PAYLOAD (Data being sent to API):');
      final formattedData = formatData(options.data);
      final dataLines = formattedData.split('\n');
      for (String line in dataLines) {
        content.writeln('│  $line');
      }
    } else {
      content.writeln('├─ PAYLOAD: No data sent');
    }

    content.writeln('└─ END OF REQUEST');

    _printBorderedBox(
      title: 'API REQUEST',
      icon: '📤',
      content: content.toString(),
    );
  }

  static void logDioResponse(Response<dynamic> response) {
    final RequestOptions ro = response.requestOptions;
    final StringBuffer content = StringBuffer();

    content.writeln('┌─ STATUS CODE: ${response.statusCode} ${_getStatusIcon(response.statusCode)}');
    content.writeln('├─ URL: ${ro.uri}');
    content.writeln('├─ METHOD: ${ro.method}');

    // Response Headers
    if (response.headers != null && response.headers.map.isNotEmpty) {
      content.writeln('├─ RESPONSE HEADERS:');
      response.headers.map.forEach((key, values) {
        content.writeln('│  • $key: ${values.join(', ')}');
      });
    }

    // Response Data
    content.writeln('├─ RESPONSE DATA (Received from API):');
    if (response.data != null) {
      final formattedData = formatData(response.data);
      final dataLines = formattedData.split('\n');
      for (String line in dataLines) {
        content.writeln('│  $line');
      }
    } else {
      content.writeln('│  null');
    }

    content.writeln('└─ END OF RESPONSE');

    _printBorderedBox(
      title: 'API RESPONSE',
      icon: '📥',
      content: content.toString(),
      status: '${response.statusCode}',
      isError: response.statusCode != null && response.statusCode! >= 400,
    );
  }

  static void logDioError(DioException err) {
    final RequestOptions ro = err.requestOptions;
    final StringBuffer content = StringBuffer();

    content.writeln('┌─ ERROR TYPE: ${err.type} ❌');
    content.writeln('├─ URL: ${ro.uri}');
    content.writeln('├─ METHOD: ${ro.method}');
    content.writeln('├─ MESSAGE: ${err.message}');

    if (err.response != null) {
      content.writeln('├─ STATUS CODE: ${err.response?.statusCode}');
      content.writeln('├─ ERROR RESPONSE DATA:');
      if (err.response?.data != null) {
        final formattedData = formatData(err.response?.data);
        final dataLines = formattedData.split('\n');
        for (String line in dataLines) {
          content.writeln('│  $line');
        }
      } else {
        content.writeln('│  null');
      }
    } else {
      content.writeln('├─ RESPONSE: null');
    }

    // Show what was sent when error occurred
    if (ro.data != null) {
      content.writeln('├─ PAYLOAD THAT WAS SENT:');
      final formattedData = formatData(ro.data);
      final dataLines = formattedData.split('\n');
      for (String line in dataLines) {
        content.writeln('│  $line');
      }
    }

    content.writeln('└─ END OF ERROR');

    _printBorderedBox(
      title: 'API ERROR',
      icon: '⚠️',
      content: content.toString(),
      isError: true,
    );

    // Also log with error method for Crashlytics
    error('DioError: ${err.message}', err, err.stackTrace);
  }

  static String _getStatusIcon(int? statusCode) {
    if (statusCode == null) return '❓';
    if (statusCode >= 200 && statusCode < 300) return '✅';
    if (statusCode >= 300 && statusCode < 400) return '↪️';
    if (statusCode >= 400 && statusCode < 500) return '⚠️';
    if (statusCode >= 500) return '💥';
    return '❓';
  }

  // Helper method to log custom API events
  static void logCustomApiEvent(String title, Map<String, dynamic> data) {
    final StringBuffer content = StringBuffer();
    content.writeln('┌─ EVENT: $title');
    content.writeln('├─ DATA:');
    final formattedData = formatData(data);
    final dataLines = formattedData.split('\n');
    for (String line in dataLines) {
      content.writeln('│  $line');
    }
    content.writeln('└─ END OF EVENT');

    _printBorderedBox(
      title: 'API EVENT',
      icon: '🔔',
      content: content.toString(),
    );
  }
}