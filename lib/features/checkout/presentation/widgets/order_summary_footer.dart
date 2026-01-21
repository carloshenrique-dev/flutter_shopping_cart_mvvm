import 'package:flutter/material.dart';

import '../strings/checkout_strings.dart';

final class OrderSummaryFooter extends StatelessWidget {
  const OrderSummaryFooter({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.onNewOrder,
  });

  final double subtotal;
  final double shipping;
  final double total;
  final VoidCallback onNewOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(CheckoutStrings.subtotalLabel),
                Text(CheckoutStrings.priceFormat(subtotal)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(CheckoutStrings.shippingLabel),
                Text(CheckoutStrings.priceFormat(shipping)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  CheckoutStrings.totalLabel,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  CheckoutStrings.priceFormat(total),
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
              height: 45,
              child: ElevatedButton(
                onPressed: onNewOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text(
                  CheckoutStrings.newOrderButton,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
