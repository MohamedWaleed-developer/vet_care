import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../data/models/checkout_draft.dart';

class CheckoutStep1Screen extends StatefulWidget {
  const CheckoutStep1Screen({super.key});

  @override
  State<CheckoutStep1Screen> createState() => _CheckoutStep1ScreenState();
}

class _CheckoutStep1ScreenState extends State<CheckoutStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  String _shippingMethod = 'standard';

  static const _green = Color(0xFF1E6554);
  static final _money = NumberFormat.currency(locale: 'ar_EG', symbol: 'ج.م', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _name = TextEditingController(text: user?.displayName ?? '');
    _phone = TextEditingController(text: user?.phoneNumber ?? '');
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    try {
      final profile = await sl<ProfileRepository>().getProfile();
      if (!mounted) return;
      if (_name.text.trim().isEmpty) _name.text = profile.name;
      if (_phone.text.trim().isEmpty) _phone.text = profile.phoneNumber;
    } catch (_) {}
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(title: const Text('بيانات التوصيل'), centerTitle: true),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _StepHeader(title: 'عنوان الشحن', subtitle: 'اكتب بيانات التوصيل لإتمام الطلب'),
                const SizedBox(height: 20),
                _field(_name, 'اسم المستلم', Icons.person_outline),
                _field(_phone, 'رقم الهاتف', Icons.phone_outlined, keyboardType: TextInputType.phone),
                _field(_city, 'المحافظة / المدينة', Icons.location_city_outlined),
                _field(_address, 'العنوان بالتفصيل', Icons.location_on_outlined, maxLines: 2),
                _field(_notes, 'ملاحظات للمندوب (اختياري)', Icons.notes_outlined, required: false),
                const SizedBox(height: 8),
                const _StepHeader(title: 'طريقة التوصيل', subtitle: 'أسعار تجريبية بالجنيه المصري'),
                const SizedBox(height: 12),
                _shippingOption('standard', 'توصيل عادي', 'خلال 3 إلى 5 أيام', 15),
                _shippingOption('express', 'توصيل سريع', 'خلال يوم إلى يومين', 30),
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _green),
                    onPressed: _continueToPayment,
                    child: const Text('متابعة للدفع'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: required
            ? (value) => value == null || value.trim().isEmpty ? 'الحقل مطلوب' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _shippingOption(String value, String title, String subtitle, num fee) {
    return Card(
      color: Colors.white,
      child: RadioListTile<String>(
        value: value,
        groupValue: _shippingMethod,
        activeColor: _green,
        onChanged: (next) => setState(() => _shippingMethod = next!),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        secondary: Text(_money.format(fee), style: const TextStyle(color: _green, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _continueToPayment() {
    if (!_formKey.currentState!.validate()) return;
    final draft = CheckoutDraft(
      customerName: _name.text.trim(),
      phoneNumber: _phone.text.trim(),
      city: _city.text.trim(),
      address: _address.text.trim(),
      deliveryNotes: _notes.text.trim(),
      shippingMethod: _shippingMethod,
      deliveryFee: _shippingMethod == 'express' ? 30 : 15,
    );
    Navigator.pushNamed(context, RouteNames.payment, arguments: draft);
  }
}

class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      );
}
