import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/presentation/viewmodels/cart_store.dart';
import '../strings/catalog_strings.dart';
import '../viewmodels/products_viewmodel.dart';
import '../widgets/product_card.dart';

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
        title: const Text(CatalogStrings.appBarTitle),
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
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '$totalQuantity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
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
        builder: (context, viewModel, child) => switch (viewModel.state) {
          ViewState.initial ||
          ViewState.loading => const Center(child: CircularProgressIndicator()),
          ViewState.error => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(viewModel.errorMessage),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadProducts(),
                  child: const Text(CatalogStrings.retryButton),
                ),
              ],
            ),
          ),
          ViewState.loaded => GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: viewModel.products.length,
            itemBuilder: (context, index) =>
                ProductCard(product: viewModel.products[index]),
          ),
        },
      ),
    );
  }
}
