import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_shopping_cart_mvvm/features/catalog/data/services/products_api.dart';
import 'package:flutter_shopping_cart_mvvm/features/catalog/domain/models/product.dart';
import 'package:flutter_shopping_cart_mvvm/features/catalog/presentation/viewmodels/products_viewmodel.dart';
import 'package:flutter_shopping_cart_mvvm/features/cart/data/services/cart_api.dart';
import 'package:flutter_shopping_cart_mvvm/features/cart/domain/models/cart.dart';
import 'package:flutter_shopping_cart_mvvm/features/cart/domain/models/cart_item.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/data/services/checkout_api.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/domain/models/checkout_result.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:flutter_shopping_cart_mvvm/features/core/presentation/viewmodels/cart_store.dart';

final class MockProductsApi extends Mock implements ProductsApi {}

final class MockCartApi extends Mock implements CartApi {}

final class MockCheckoutApi extends Mock implements CheckoutApi {}

final class FakeCartItem extends Fake implements CartItem {}

final class FakeCart extends Fake implements Cart {}

sealed class TestHelpers {
  static Product createTestProduct({
    int id = 1,
    String title = 'Test Product',
    double price = 10.0,
    String description = 'Test Description',
    String category = 'Test Category',
    String image = 'https://example.com/image.png',
  }) => Product(
    id: id,
    title: title,
    price: price,
    description: description,
    category: category,
    image: image,
  );

  static CartItem createTestCartItem({Product? product, int quantity = 1}) =>
      CartItem(product: product ?? createTestProduct(), quantity: quantity);

  static Cart createTestCart({List<CartItem>? items}) =>
      Cart(items: items ?? []);

  static CheckoutResult createTestCheckoutResult({
    String orderId = 'ORD-123456',
    double shipping = 5.99,
    double total = 15.99,
  }) => CheckoutResult(orderId: orderId, shipping: shipping, total: total);

  static List<Product> createTestProductList({int count = 3}) => List.generate(
    count,
    (index) => createTestProduct(
      id: index + 1,
      title: 'Product ${index + 1}',
      price: (index + 1) * 10.0,
    ),
  );

  static Widget createWidgetUnderTest({
    required Widget child,
    CartStore? cartStore,
    ProductsViewModel? productsViewModel,
    CheckoutViewModel? checkoutViewModel,
    NavigatorObserver? navigatorObserver,
  }) => MultiProvider(
    providers: [
      ChangeNotifierProvider<CartStore>.value(value: cartStore ?? CartStore()),
      ChangeNotifierProvider<ProductsViewModel>.value(
        value: productsViewModel ?? ProductsViewModel(),
      ),
      ChangeNotifierProvider<CheckoutViewModel>.value(
        value: checkoutViewModel ?? CheckoutViewModel(),
      ),
    ],
    child: MaterialApp(
      home: child,
      navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
      routes: {
        '/cart': (context) => const Scaffold(body: Text('Cart Screen')),
        '/order-complete': (context) =>
            const Scaffold(body: Text('Order Complete Screen')),
      },
    ),
  );

  static Widget createWidgetWithNavigation({
    required Widget child,
    CartStore? cartStore,
    ProductsViewModel? productsViewModel,
    CheckoutViewModel? checkoutViewModel,
    String initialRoute = '/',
    Map<String, WidgetBuilder>? routes,
  }) => MultiProvider(
    providers: [
      ChangeNotifierProvider<CartStore>.value(value: cartStore ?? CartStore()),
      ChangeNotifierProvider<ProductsViewModel>.value(
        value: productsViewModel ?? ProductsViewModel(),
      ),
      ChangeNotifierProvider<CheckoutViewModel>.value(
        value: checkoutViewModel ?? CheckoutViewModel(),
      ),
    ],
    child: MaterialApp(
      initialRoute: initialRoute,
      routes:
          routes ??
          {
            '/': (context) => child,
            '/cart': (context) => const Scaffold(body: Text('Cart Screen')),
            '/order-complete': (context) =>
                const Scaffold(body: Text('Order Complete Screen')),
          },
    ),
  );
}
