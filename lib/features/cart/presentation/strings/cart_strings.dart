sealed class CartStrings {
  static const String appBarTitle = 'Cart';
  static const String emptyCartMessage = 'Your cart is empty';
  static const String dismissAction = 'Dismiss';
  static const String subtotalLabel = 'Subtotal:';
  static const String totalLabel = 'Total:';
  static const String checkoutButton = 'Checkout';
  static const String removeButton = 'Remove';

  static String priceFormat(double price) => '\$${price.toStringAsFixed(2)}';
  static String subtotalFormat(double subtotal) =>
      'Subtotal: \$${subtotal.toStringAsFixed(2)}';
}
