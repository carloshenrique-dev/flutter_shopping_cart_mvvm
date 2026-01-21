import 'package:flutter/foundation.dart';

import '../../../core/domain/models/checkout_state.dart';
import '../../data/services/checkout_api.dart';
import '../../../cart/domain/models/cart.dart';
import '../../../cart/domain/models/cart_item.dart';
import '../../domain/models/checkout_result.dart';

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

  double get subtotal =>
      _orderItems.fold(0.0, (sum, item) => sum + item.subtotal);

  void reset() {
    _state = CheckoutState.initial;
    _errorMessage = null;
    _result = null;
    _orderItems = [];
    notifyListeners();
  }
}
