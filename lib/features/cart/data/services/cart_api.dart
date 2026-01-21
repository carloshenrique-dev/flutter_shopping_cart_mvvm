import 'dart:math';

import '../../domain/models/cart_item.dart';

class CartApi {
  Future<void> removeItem(CartItem item) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (Random().nextBool()) {
      throw Exception('Failed to remove item. Please try again.');
    }
  }

  Future<void> updateQuantity(CartItem item, int quantity) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
