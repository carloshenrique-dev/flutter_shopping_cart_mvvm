import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/viewmodels/cart_store.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/order_summary.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartViewModel(cartStore: context.read<CartStore>()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: Consumer2<CartStore, CartViewModel>(
          builder: (context, cartStore, cartViewModel, child) {
            if (cartViewModel.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(cartViewModel.errorMessage!),
                    backgroundColor: Colors.red,
                    action: SnackBarAction(
                      label: 'Dismiss',
                      textColor: Colors.white,
                      onPressed: () => cartViewModel.clearError(),
                    ),
                  ),
                );
                cartViewModel.clearError();
              });
            }

            final cart = cartStore.cart;

            if (cart.items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      return CartItemCard(
                        item: cart.items[index],
                        isRemoving: cartViewModel.isRemoving,
                      );
                    },
                  ),
                ),
                OrderSummary(subtotal: cart.subtotal),
              ],
            );
          },
        ),
      ),
    );
  }
}
