import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/catalog/catalog.dart';
import 'features/cart/cart.dart';
import 'features/core/presentation/app_theme.dart';
import 'features/core/presentation/viewmodels/cart_store.dart';
import 'features/checkout/checkout.dart';

void main() {
  runApp(const MainApp());
}

final class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartStore()),
        ChangeNotifierProvider(create: (_) => ProductsViewModel()),
        ChangeNotifierProvider(create: (_) => CheckoutViewModel()),
      ],
      child: MaterialApp(
        title: 'Shopping Cart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/',
        routes: {
          '/': (context) => const CatalogView(),
          '/cart': (context) => const CartView(),
          '/order-complete': (context) => const OrderCompleteView(),
        },
      ),
    );
  }
}
