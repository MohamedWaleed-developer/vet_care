class CheckoutDraft {
  final String customerName;
  final String phoneNumber;
  final String city;
  final String address;
  final String deliveryNotes;
  final String shippingMethod;
  final num deliveryFee;

  const CheckoutDraft({
    required this.customerName,
    required this.phoneNumber,
    required this.city,
    required this.address,
    required this.deliveryNotes,
    required this.shippingMethod,
    required this.deliveryFee,
  });

  Map<String, dynamic> toShippingAddressMap() => {
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'city': city,
        'address': address,
        'deliveryNotes': deliveryNotes,
      };
}
