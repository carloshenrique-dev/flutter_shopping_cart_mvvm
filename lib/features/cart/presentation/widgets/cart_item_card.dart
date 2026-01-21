import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/viewmodels/cart_store.dart';
import '../../domain/models/cart_item.dart';
import '../viewmodels/cart_viewmodel.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool isRemoving;

  const CartItemCard({super.key, required this.item, required this.isRemoving});

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.read<CartViewModel>();
    final cartStore = context.read<CartStore>();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Image.network(
                item.product.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => cartStore.removeProduct(item.product),
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => cartStore.addProduct(item.product),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: isRemoving
                      ? null
                      : () => cartViewModel.removeItem(item),
                  icon: isRemoving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                    'Remove',
                    style: TextStyle(
                      color: isRemoving ? Colors.grey : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
