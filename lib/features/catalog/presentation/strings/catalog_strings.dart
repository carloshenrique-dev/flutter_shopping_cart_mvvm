sealed class CatalogStrings {
  static const String appBarTitle = 'Catalog';
  static const String retryButton = 'Retry';
  static const String addToCartButton = 'Add to Cart';
  static const String cartFullButton = 'Cart Full';

  static String priceFormat(double price) => '\$${price.toStringAsFixed(2)}';
}
