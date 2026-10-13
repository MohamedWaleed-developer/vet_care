import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient({
    String? baseUrl,
  }) : dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );
}