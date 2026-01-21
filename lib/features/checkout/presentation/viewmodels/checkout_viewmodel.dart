import 'package:flutter/foundation.dart';

import '../../data/services/checkout_api.dart';
import '../../../cart/domain/models/cart.dart';
import '../../../cart/domain/models/cart_item.dart';

enum CheckoutState { initial, processing, success, error }

class CheckoutViewModel extends ChangeNotifier {
  final CheckoutApi _api;

  CheckoutViewModel({CheckoutApi? api}) : _api = api ?? CheckoutApi();

  CheckoutState _state = CheckoutState.initial;
  String? _errorMessage;
  CheckoutResult? _result;
  List<CartItem> _orderItems = [];

  CheckoutState get state => _state;
  String? get errorMessage => _errorMessage;
  CheckoutResult? get result => _result;
  List<CartItem> get orderItems => _orderItems;

  Future<void> processCheckout(Cart cart) async {
    _state = CheckoutState.processing;
    _orderItems = List.from(cart.items);
    notifyListeners();

    try {
      _result = await _api.checkout(cart);
      _state = CheckoutState.success;
    } catch (e) {
      _errorMessage = 'Failed to process checkout. Please try again.';
      _state = CheckoutState.error;
    }

    notifyListeners();
  }

  void reset() {
    _state = CheckoutState.initial;
    _errorMessage = null;
    _result = null;
    _orderItems = [];
    notifyListeners();
  }
}
