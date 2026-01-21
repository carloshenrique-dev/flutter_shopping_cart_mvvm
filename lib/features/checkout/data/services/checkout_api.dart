import '../../../cart/domain/models/cart.dart';

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

class CheckoutApi {
  Future<CheckoutResult> checkout(Cart cart) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    const shipping = 5.99;
    final total = cart.subtotal + shipping;

    return CheckoutResult(
      orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      shipping: shipping,
      total: total,
    );
  }
}
