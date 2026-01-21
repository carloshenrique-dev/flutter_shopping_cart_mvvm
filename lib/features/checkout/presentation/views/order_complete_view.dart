import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../strings/checkout_strings.dart';

import '../viewmodels/checkout_viewmodel.dart';
import '../widgets/order_summary_footer.dart';

final class OrderCompleteView extends StatelessWidget {
  const OrderCompleteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CheckoutViewModel>(
        builder: (context, checkoutViewModel, child) {
          final result = checkoutViewModel.result;
          final items = checkoutViewModel.orderItems;

          if (result == null) {
            return const Center(
              child: Text(CheckoutStrings.noOrderDataMessage),
            );
          }

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 80,
                            ),
                            SizedBox(height: 16),
                            Text(
                              CheckoutStrings.thankYouMessage,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          CheckoutStrings.orderIdFormat(result.orderId),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        CheckoutStrings.orderItemsTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...items.map(
                        (item) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          child: ListTile(
                            leading: SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.network(
                                item.product.image,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            ),
                            title: Text(
                              item.product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              CheckoutStrings.priceWithQuantity(
                                item.product.price,
                                item.quantity,
                              ),
                            ),
                            trailing: Text(
                              CheckoutStrings.priceFormat(item.subtotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                OrderSummaryFooter(
                  subtotal: checkoutViewModel.subtotal,
                  shipping: result.shipping,
                  total: result.total,
                  onNewOrder: () {
                    checkoutViewModel.reset();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
