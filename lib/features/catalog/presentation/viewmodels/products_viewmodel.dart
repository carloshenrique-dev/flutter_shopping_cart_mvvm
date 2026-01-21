import 'package:flutter/foundation.dart';

import '../../data/services/products_api.dart';
import '../../domain/models/product.dart';

enum ViewState { initial, loading, loaded, error }

class ProductsViewModel extends ChangeNotifier {
  final ProductsApi _api;

  ProductsViewModel({ProductsApi? api}) : _api = api ?? ProductsApi();

  ViewState _state = ViewState.initial;
  List<Product> _products = [];
  String _errorMessage = '';

  ViewState get state => _state;
  List<Product> get products => _products;
  String get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _products = await _api.getProducts();
      _state = ViewState.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load products. Please try again.';
      _state = ViewState.error;
    }

    notifyListeners();
  }
}
