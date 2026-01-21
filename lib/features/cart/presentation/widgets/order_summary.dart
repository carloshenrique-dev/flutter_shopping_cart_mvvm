import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/viewmodels/cart_store.dart';
import '../../../checkout/presentation/viewmodels/checkout_viewmodel.dart';

final class OrderSummary extends StatelessWidget {
  final double subtotal;

  const OrderSummary({super.key, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Consumer<CheckoutViewModel>(
                builder: (context, checkoutViewModel, child) {
                  final isProcessing =
                      checkoutViewModel.state == CheckoutState.processing;
                  return ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            final cartStore = context.read<CartStore>();
                            await checkoutViewModel.processCheckout(
                              cartStore.cart,
                            );
                            if (checkoutViewModel.state ==
                                    CheckoutState.success &&
                                context.mounted) {
                              cartStore.clearCart();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/order-complete',
                                (route) => false,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Checkout',
                            style: TextStyle(fontSize: 18),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
