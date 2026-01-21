import 'package:flutter/foundation.dart';

import '../../data/services/cart_api.dart';
import '../../../core/presentation/viewmodels/cart_store.dart';
import '../../domain/models/cart_item.dart';

class CartViewModel extends ChangeNotifier {
  final CartStore _cartStore;
  final CartApi _api;

  CartViewModel({
    required CartStore cartStore,
    CartApi? api,
  })  : _cartStore = cartStore,
        _api = api ?? CartApi();

  bool _isRemoving = false;
  String? _errorMessage;

  bool get isRemoving => _isRemoving;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> removeItem(CartItem item) async {
    _isRemoving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.removeItem(item);
      _cartStore.removeItem(item);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isRemoving = false;
    notifyListeners();
  }

  Future<void> updateQuantity(CartItem item, int quantity) async {
    try {
      await _api.updateQuantity(item, quantity);
      _cartStore.updateQuantity(item, quantity);
    } catch (e) {
      _errorMessage = 'Failed to update quantity';
      notifyListeners();
    }
  }
}
