import 'package:dio/dio.dart';

import 'image_service.dart';

class ExternalImageService implements ImageService {
  final Dio dio;
  final String uploadUrl;
  final String? apiKey;

  ExternalImageService({
    required this.dio,
    required this.uploadUrl,
    this.apiKey,
  });

  @override
  Future<String> uploadImage({
    required String filePath,
    String? folder,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      if (folder != null) 'folder': folder,
    });

    final response = await dio.post(
      uploadUrl,
      data: formData,
      options: Options(
        headers: {
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
        },
      ),
    );

    final data = response.data;

    if (data is Map<String, dynamic> && data['url'] is String) {
      return data['url'] as String;
    }

    throw Exception('Image URL was not returned by image provider.');
  }

  @override
  Future<void> deleteImage({
    required String imageUrl,
  }) async {
    // Deletion depends on the selected image hosting provider.
  }
}