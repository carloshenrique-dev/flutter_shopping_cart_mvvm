sealed class CheckoutStrings {
  static const String noOrderDataMessage = 'No order data available';
  static const String thankYouMessage = 'Thank you for your order!';
  static const String orderItemsTitle = 'Order Items';
  static const String subtotalLabel = 'Subtotal:';
  static const String shippingLabel = 'Shipping:';
  static const String totalLabel = 'Total:';
  static const String newOrderButton = 'New Order';

  static String orderIdFormat(String orderId) => 'Order ID: $orderId';
  static String priceFormat(double price) => '\$${price.toStringAsFixed(2)}';
  static String priceWithQuantity(double price, int quantity) =>
      '\$${price.toStringAsFixed(2)} x $quantity';
}
