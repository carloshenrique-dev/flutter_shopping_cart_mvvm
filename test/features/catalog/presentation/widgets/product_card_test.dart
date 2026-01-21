import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import 'package:flutter_shopping_cart_mvvm/features/catalog/presentation/strings/catalog_strings.dart';
import 'package:flutter_shopping_cart_mvvm/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter_shopping_cart_mvvm/features/core/presentation/viewmodels/cart_store.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late CartStore cartStore;
  final product = TestHelpers.createTestProduct();

  setUp(() {
    cartStore = CartStore();
  });

  Widget createWidget(product) {
    return ChangeNotifierProvider<CartStore>.value(
      value: cartStore,
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: ProductCard(product: product),
          ),
        ),
      ),
    );
  }

  group('ProductCard', () {
    testWidgets('GIVEN a product with title '
        'WHEN card is displayed '
        'THEN should display product title', (tester) async {
      await mockNetworkImagesFor(() async {
        final product = TestHelpers.createTestProduct(
          title: 'Test Product Title',
        );

        await tester.pumpWidget(createWidget(product));

        expect(find.text('Test Product Title'), findsOneWidget);
      });
    });

    testWidgets('GIVEN a product with price '
        'WHEN card is displayed '
        'THEN should display product price', (tester) async {
      await mockNetworkImagesFor(() async {
        final product = TestHelpers.createTestProduct(price: 29.99);

        await tester.pumpWidget(createWidget(product));

        expect(find.text(CatalogStrings.priceFormat(29.99)), findsOneWidget);
      });
    });

    testWidgets('GIVEN product is not in cart '
        'WHEN card is displayed '
        'THEN should display Add to Cart button', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget(product));

        expect(find.text(CatalogStrings.addToCartButton), findsOneWidget);
      });
    });

    testWidgets('GIVEN product is not in cart '
        'WHEN Add to Cart is pressed '
        'THEN should add product to cart', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget(product));
        await tester.tap(find.text(CatalogStrings.addToCartButton));
        await tester.pump();

        expect(cartStore.cart.items.length, 1);
        expect(cartStore.cart.items.first.product.id, product.id);
      });
    });

    testWidgets('GIVEN product is in cart '
        'WHEN card is displayed '
        'THEN should display quantity controls', (tester) async {
      await mockNetworkImagesFor(() async {
        cartStore.addProduct(product);

        await tester.pumpWidget(createWidget(product));

        expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      });
    });

    testWidgets('GIVEN product is in cart '
        'WHEN plus button is pressed '
        'THEN should increment quantity', (tester) async {
      await mockNetworkImagesFor(() async {
        cartStore.addProduct(product);

        await tester.pumpWidget(createWidget(product));
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
        expect(cartStore.cart.items.first.quantity, 2);
      });
    });

    testWidgets('GIVEN product has quantity 2 in cart '
        'WHEN minus button is pressed '
        'THEN should decrement quantity', (tester) async {
      await mockNetworkImagesFor(() async {
        cartStore.addProduct(product);
        cartStore.addProduct(product);

        await tester.pumpWidget(createWidget(product));
        expect(find.text('2'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pump();

        expect(find.text('1'), findsOneWidget);
        expect(cartStore.cart.items.first.quantity, 1);
      });
    });

    testWidgets('GIVEN product has quantity 1 in cart '
        'WHEN minus button is pressed '
        'THEN should remove product from cart', (tester) async {
      await mockNetworkImagesFor(() async {
        cartStore.addProduct(product);

        await tester.pumpWidget(createWidget(product));
        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pump();

        expect(cartStore.cart.items, isEmpty);
        expect(find.text(CatalogStrings.addToCartButton), findsOneWidget);
      });
    });

    testWidgets('GIVEN cart is at max capacity '
        'WHEN card is displayed for new product '
        'THEN should display Cart Full', (tester) async {
      await mockNetworkImagesFor(() async {
        for (var i = 0; i < CartStore.maxDifferentProducts; i++) {
          cartStore.addProduct(TestHelpers.createTestProduct(id: i));
        }

        final newProduct = TestHelpers.createTestProduct(id: 100);

        await tester.pumpWidget(createWidget(newProduct));

        expect(find.text(CatalogStrings.cartFullButton), findsOneWidget);
      });
    });

    testWidgets('GIVEN cart is full '
        'WHEN card is displayed for new product '
        'THEN should disable button', (tester) async {
      await mockNetworkImagesFor(() async {
        for (var i = 0; i < CartStore.maxDifferentProducts; i++) {
          cartStore.addProduct(TestHelpers.createTestProduct(id: i));
        }

        final newProduct = TestHelpers.createTestProduct(id: 100);

        await tester.pumpWidget(createWidget(newProduct));

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);
      });
    });

    testWidgets('GIVEN a product with image '
        'WHEN card is displayed '
        'THEN should display product image', (tester) async {
      await mockNetworkImagesFor(() async {
        final product = TestHelpers.createTestProduct(
          image: 'https://example.com/image.png',
        );

        await tester.pumpWidget(createWidget(product));

        expect(find.byType(Image), findsOneWidget);
      });
    });
  });
}
