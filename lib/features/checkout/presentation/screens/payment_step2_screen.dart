import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/route_names.dart';
import '../../../cart/data/repositories/cart_repository.dart';
import '../../data/models/checkout_draft.dart';
import '../cubit/checkout_cubit.dart';

class PaymentStep2Screen extends StatelessWidget {
  final CheckoutDraft draft;

  const PaymentStep2Screen({super.key, required this.draft});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => sl<CheckoutCubit>(),
        child: _PaymentView(draft: draft),
      );
}

class _PaymentView extends StatefulWidget {
  final CheckoutDraft draft;

  const _PaymentView({required this.draft});

  @override
  State<_PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<_PaymentView> {
  String _method = 'card_simulated';
  late Future<num> _subtotal;
  static const _green = Color(0xFF1E6554);
  static final _money = NumberFormat.currency(locale: 'ar_EG', symbol: 'ج.م', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _subtotal = sl<CartRepository>()
        .getItems()
        .then((items) => items.fold<num>(0, (sum, item) => sum + item.totalPrice));
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(title: const Text('الدفع وتأكيد الطلب'), centerTitle: true),
          body: SafeArea(
            child: BlocConsumer<CheckoutCubit, CheckoutState>(
              listener: (context, state) {
                if (state.completedOrder != null) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.paymentSuccess,
                    (route) => route.settings.name == RouteNames.home,
                    arguments: state.completedOrder,
                  );
                }
              },
              builder: (context, state) => ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('اختار طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _methodTile('card_simulated', Icons.credit_card, 'بطاقة بنكية (محاكاة)', 'تجربة نجاح أو فشل بدون خصم أموال'),
                  _methodTile('cash_on_delivery', Icons.local_shipping_outlined, 'الدفع عند الاستلام', 'تسدد للمندوب عند وصول الطلب'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFE6F3EF), borderRadius: BorderRadius.circular(14)),
                    child: const Text('وضع تجريبي: لا تدخل بيانات بطاقة حقيقية، ولن يتم خصم أي مبلغ.'),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<num>(
                    future: _subtotal,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Text('تعذر تحميل إجمالي السلة.');
                      if (!snapshot.hasData) return const LinearProgressIndicator();
                      return Column(children: [
                        _summaryRow('المنتجات', _money.format(snapshot.data!)),
                        const SizedBox(height: 10),
                        _summaryRow('التوصيل', _money.format(widget.draft.deliveryFee)),
                        const Divider(height: 24),
                        _summaryRow('الإجمالي', _money.format(snapshot.data! + widget.draft.deliveryFee)),
                      ]);
                    },
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: _green),
                      onPressed: state.isSubmitting ? null : () => _confirm(context),
                      child: state.isSubmitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('تأكيد الطلب'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _methodTile(String value, IconData icon, String title, String subtitle) => Card(
        color: Colors.white,
        child: RadioListTile<String>(
          value: value,
          groupValue: _method,
          activeColor: _green,
          onChanged: (next) => setState(() => _method = next!),
          secondary: Icon(icon, color: _green),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
        ),
      );

  Widget _summaryRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      );

  Future<void> _confirm(BuildContext context) async {
    bool? simulationResult;
    if (_method == 'card_simulated') {
      simulationResult = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('محاكاة الدفع'),
          content: const Text('اختر النتيجة التجريبية. لا توجد عملية خصم حقيقية.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('محاكاة فشل')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('محاكاة نجاح')),
          ],
        ),
      );
      if (simulationResult == null || !mounted) return;
    }
    final cubit = context.read<CheckoutCubit>();
    final success = await cubit.submit(
      draft: widget.draft,
      paymentMethod: _method,
      simulatedSuccess: simulationResult,
    );
    if (!mounted || success || _method == 'cash_on_delivery') return;
    if (cubit.state.paymentFailed) {
      Navigator.pushNamed(context, RouteNames.paymentFailed, arguments: cubit.state.errorMessage);
    }
  }
}
