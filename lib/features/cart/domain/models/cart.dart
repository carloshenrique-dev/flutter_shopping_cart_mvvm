import 'cart_item.dart';

class Cart {
  final List<CartItem> items;

  const Cart({this.items = const []});

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  int get itemCount => items.length;

  Cart copyWith({List<CartItem>? items}) {
    return Cart(items: items ?? this.items);
  }
}
