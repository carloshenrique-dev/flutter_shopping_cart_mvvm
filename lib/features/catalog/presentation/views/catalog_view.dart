import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/product.dart';
import '../../../../core/presentation/viewmodels/cart_store.dart';
import '../viewmodels/products_viewmodel.dart';

class CatalogView extends StatefulWidget {
  const CatalogView({super.key});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsViewModel>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        actions: [
          Consumer<CartStore>(
            builder: (context, cartStore, child) {
              final totalQuantity = cartStore.cart.totalQuantity;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (totalQuantity > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Text(
                          '$totalQuantity',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductsViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.state) {
            case ViewState.initial:
            case ViewState.loading:
              return const Center(child: CircularProgressIndicator());
            case ViewState.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewModel.errorMessage),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.loadProducts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            case ViewState.loaded:
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: viewModel.products.length,
                itemBuilder: (context, index) {
                  return _ProductCard(product: viewModel.products[index]);
                },
              );
          }
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 48),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          Consumer<CartStore>(
            builder: (context, cartStore, child) {
              final quantity = cartStore.getQuantity(product.id);
              final canAdd = cartStore.canAddProduct(product);

              if (quantity == 0) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: canAdd ? () => cartStore.addProduct(product) : null,
                    child: Text(canAdd ? 'Add to Cart' : 'Cart Full'),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => cartStore.removeProduct(product),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => cartStore.addProduct(product),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
