class CheckoutResult {
  final String orderId;
  final double shipping;
  final double total;

  const CheckoutResult({
    required this.orderId,
    required this.shipping,
    required this.total,
  });
}
