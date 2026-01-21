import 'package:flutter/foundation.dart';

import '../../../features/cart/domain/models/cart.dart';
import '../../../features/cart/domain/models/cart_item.dart';
import '../../../features/catalog/domain/models/product.dart';

class CartStore extends ChangeNotifier {
  static const maxDifferentProducts = 10;

  Cart _cart = const Cart();

  Cart get cart => _cart;

  bool canAddProduct(Product product) {
    final existingItem = _cart.items
        .where((item) => item.product.id == product.id)
        .firstOrNull;
    if (existingItem != null) return true;
    return _cart.itemCount < maxDifferentProducts;
  }

  int getQuantity(int productId) {
    final item = _cart.items
        .where((item) => item.product.id == productId)
        .firstOrNull;
    return item?.quantity ?? 0;
  }

  void addProduct(Product product) {
    if (!canAddProduct(product)) return;

    final items = List<CartItem>.from(_cart.items);
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }

    _cart = _cart.copyWith(items: items);
    notifyListeners();
  }

  void removeProduct(Product product) {
    final items = List<CartItem>.from(_cart.items);
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index < 0) return;

    if (items[index].quantity > 1) {
      items[index] = items[index].copyWith(quantity: items[index].quantity - 1);
    } else {
      items.removeAt(index);
    }

    _cart = _cart.copyWith(items: items);
    notifyListeners();
  }

  void removeItem(CartItem item) {
    final items = List<CartItem>.from(_cart.items);
    items.removeWhere((i) => i.product.id == item.product.id);
    _cart = _cart.copyWith(items: items);
    notifyListeners();
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      removeItem(item);
      return;
    }

    final items = List<CartItem>.from(_cart.items);
    final index = items.indexWhere((i) => i.product.id == item.product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: quantity);
      _cart = _cart.copyWith(items: items);
      notifyListeners();
    }
  }

  void clearCart() {
    _cart = const Cart();
    notifyListeners();
  }
}
