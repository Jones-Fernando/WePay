import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/api_services.dart';

class ApiClient {
  late final Dio dio;

  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:5000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    return 'http://127.0.0.1:5000/api';
  }

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (ApiService.authToken != null) {
          options.headers['Authorization'] = 'Bearer ${ApiService.authToken}';
        }
        handler.next(options);
      },
    ));
  }
}