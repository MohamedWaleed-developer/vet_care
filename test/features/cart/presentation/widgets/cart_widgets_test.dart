import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vet_care/features/cart/presentation/cubit/cart_state.dart';
import 'package:vet_care/features/cart/presentation/widgets/cart_coupon_box.dart';
import 'package:vet_care/features/cart/presentation/widgets/cart_summary.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('coupon box explains that empty coupon codes are required', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const CartCouponBox()));

    await tester.tap(find.text('تطبيق'));
    await tester.pump();

    expect(find.text('أدخل كود الخصم أولاً.'), findsOneWidget);
  });

  testWidgets('cart summary includes delivery in the order total', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        CartSummary(
          subtotal: 100,
          deliveryFee: CartState.standardDeliveryFee,
          total: 100 + CartState.standardDeliveryFee,
          isBusy: false,
          onCheckout: () {},
        ),
      ),
    );

    expect(find.text('100.00 ج.م'), findsOneWidget);
    expect(find.text('15.00 ج.م'), findsOneWidget);
    expect(find.text('التوصيل العادي'), findsOneWidget);
    expect(find.text('115.00 ج.م'), findsOneWidget);
  });
}
