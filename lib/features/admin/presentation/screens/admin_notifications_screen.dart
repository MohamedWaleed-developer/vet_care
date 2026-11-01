import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  String _type = 'announcement';
  String _destination = 'home';
  bool _isSending = false;

  final Map<String, String> _types = {
    'announcement': 'إعلان عام',
    'offer': 'عرض أو خصم',
    'product': 'منتج جديد',
    'category': 'قسم جديد',
  };

  final Map<String, String> _destinations = {
    'home': 'الرئيسية',
    'store': 'المتجر',
    'notifications': 'قائمة الإشعارات',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate() || _isSending) return;

    setState(() => _isSending = true);

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'sendCustomerBroadcast',
      );

      await callable.call({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'type': _type,
        'destination': _destination,
      });

      if (!mounted) return;

      _titleController.clear();
      _bodyController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إرسال الإشعار بنجاح')));
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.code == 'not-found'
                ? 'خدمة الإرسال غير منشورة أو غير متاحة بعد.'
                : error.message ?? 'تعذر إرسال الإشعار.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء إرسال الإشعار.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8F7),
        appBar: AppBar(
          title: const Text('إدارة الإشعارات'),
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'إنشاء إشعار جديد',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'سيتم استهداف حسابات العملاء المؤهلة فقط '
                    'بعد إعداد خدمة الإرسال على السيرفر.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الإشعار',
                      hintText: 'مثال: عروض الجمعة البيضاء',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'اكتب عنوان الإشعار';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bodyController,
                    maxLength: 300,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'محتوى الإشعار',
                      hintText: 'اكتب تفاصيل الإعلان للعملاء',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'اكتب محتوى الإشعار';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(
                      labelText: 'نوع الإشعار',
                      border: OutlineInputBorder(),
                    ),
                    items: _types.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _type = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _destination,
                    decoration: const InputDecoration(
                      labelText: 'الوجهة عند الضغط',
                      border: OutlineInputBorder(),
                    ),
                    items: _destinations.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _destination = value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSending ? null : _sendNotification,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.notifications_active_outlined),
                    label: Text(
                      _isSending ? 'جارٍ الإرسال...' : 'إرسال للعملاء',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
