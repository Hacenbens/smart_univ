import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class LoggingInterceptor extends Interceptor {
  static File? _logFile;

  static Future<void> init() async {
    assert(() {
      _initAsync();
      return true;
    }());
  }

  static Future<void> _initAsync() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/dio_logs.txt');
      if (await _logFile!.exists()) await _logFile!.writeAsString('');
      _write('=== Session started: ${DateTime.now()} ===\n');
    } catch (_) {
      // Platform channel unavailable (tests/CI) — fall back to console only
      _logFile = null;
    }
  }

  static void _write(String line) {
    assert(() {
      debugPrint(line);
      _logFile?.writeAsStringSync('$line\n', mode: FileMode.append);
      return true;
    }());
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _write('┌── [DIO REQUEST] ────────────────────────────');
    _write('│ ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      _write('│ Query : ${options.queryParameters}');
    }
    if (options.headers.containsKey('Authorization')) {
      _write('│ Auth  : Bearer ***');
    }
    _write('└─────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    final preview = data is List
        ? 'List(${data.length} items)'
        : data.toString().length > 200
            ? '${data.toString().substring(0, 200)}…'
            : data.toString();

    _write('┌── [DIO RESPONSE] ───────────────────────────');
    _write('│ ${response.statusCode} ${response.requestOptions.uri}');
    _write('│ Data  : $preview');
    _write('└─────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _write('┌── [DIO ERROR] ──────────────────────────────');
    _write('│ Type   : ${err.type.name}');
    _write('│ Status : ${err.response?.statusCode ?? 'no response'}');
    _write('│ Message: ${err.message ?? 'null'}');
    if (err.error != null) _write('│ Error  : ${err.error}');
    _write('└─────────────────────────────────────────────');
    handler.next(err);
  }
}
