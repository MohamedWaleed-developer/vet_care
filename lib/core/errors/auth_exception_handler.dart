import 'package:firebase_auth/firebase_auth.dart';

class AuthExceptionHandler {
  static String handleException(dynamic exception) {
    if (exception is FirebaseAuthException) {
      switch (exception.code) {
        case 'user-not-found':
          return 'الحساب غير موجود، يرجى التأكد من البريد الإلكتروني.';
        case 'wrong-password':
          return 'كلمة المرور غير صحيحة.';
        case 'email-already-in-use':
          return 'هذا البريد الإلكتروني مستخدم بالفعل.';
        case 'invalid-email':
          return 'صيغة البريد الإلكتروني غير صالحة.';
        case 'weak-password':
          return 'كلمة المرور ضعيفة جداً، يرجى إدخال 6 أحرف على الأقل.';
        case 'user-disabled':
          return 'تم تعطيل هذا الحساب من قبل الإدارة.';
        case 'too-many-requests':
          return 'تم حظر الطلبات مؤقتاً لكثرة المحاولات، حاول لاحقاً.';
        case 'operation-not-allowed':
          return 'تسجيل الدخول بهذه الطريقة غير مفعّل حالياً.';
        case 'network-request-failed':
          return 'تأكد من اتصالك بالإنترنت وحاول مجدداً.';
        case 'invalid-credential':
          return 'بيانات الاعتماد غير صحيحة أو انتهت صلاحيتها.';
        default:
          return exception.message ?? 'حدث خطأ غير متوقع في المصادقة.';
      }
    }

    if (exception is String) {
      return exception;
    }

    return exception.toString().replaceAll('Exception: ', '');
  }
}