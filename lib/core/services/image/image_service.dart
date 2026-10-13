abstract class ImageService {
  Future<String> uploadImage({
    required String filePath,
    String? folder,
  });

  Future<void> deleteImage({
    required String imageUrl,
  });
}