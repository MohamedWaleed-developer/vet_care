abstract class NotificationService {
  Future<void> initialize();

  Future<void> requestPermission();

  Future<String?> getToken();

  Future<void> saveDeviceToken();

  Stream<String> get onTokenRefresh;
}