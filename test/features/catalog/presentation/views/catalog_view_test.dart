import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import 'package:flutter_shopping_cart_mvvm/features/catalog/domain/models/product.dart';

import 'package:flutter_shopping_cart_mvvm/features/catalog/presentation/strings/catalog_strings.dart';
import 'package:flutter_shopping_cart_mvvm/features/catalog/presentation/viewmodels/products_viewmodel.dart';
import 'package:flutter_shopping_cart_mvvm/features/catalog/presentation/views/catalog_view.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:flutter_shopping_cart_mvvm/features/core/presentation/viewmodels/cart_store.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late MockProductsApi mockApi;
  late ProductsViewModel productsViewModel;
  late CartStore cartStore;
  late CheckoutViewModel checkoutViewModel;

  setUp(() {
    mockApi = MockProductsApi();
    productsViewModel = ProductsViewModel(api: mockApi);
    cartStore = CartStore();
    checkoutViewModel = CheckoutViewModel();
  });

  Widget createWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartStore>.value(value: cartStore),
        ChangeNotifierProvider<ProductsViewModel>.value(
          value: productsViewModel,
        ),
        ChangeNotifierProvider<CheckoutViewModel>.value(
          value: checkoutViewModel,
        ),
      ],
      child: MaterialApp(
        home: const CatalogView(),
        routes: {
          '/cart': (context) => const Scaffold(body: Text('Cart Screen')),
        },
      ),
    );
  }

  group('CatalogView', () {
    testWidgets('GIVEN catalog view '
        'WHEN view is displayed '
        'THEN should display app bar with title', (tester) async {
      when(() => mockApi.getProducts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidget());

      expect(find.text(CatalogStrings.appBarTitle), findsOneWidget);
    });

    testWidgets('GIVEN products are loading '
        'WHEN view is displayed '
        'THEN should display loading indicator', (tester) async {
      final completer = Completer<List<Product>>();
      when(() => mockApi.getProducts()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('GIVEN products loading fails '
        'WHEN view is displayed '
        'THEN should display error message and retry button', (tester) async {
      when(() => mockApi.getProducts()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Failed to load products. Please try again.'),
        findsOneWidget,
      );
      expect(find.text(CatalogStrings.retryButton), findsOneWidget);
    });

    testWidgets('GIVEN error state '
        'WHEN retry button is pressed '
        'THEN should reload products', (tester) async {
      when(() => mockApi.getProducts()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      when(() => mockApi.getProducts()).thenAnswer((_) async => []);
      await tester.tap(find.text(CatalogStrings.retryButton));
      await tester.pumpAndSettle();

      verify(() => mockApi.getProducts()).called(2);
    });

    testWidgets('GIVEN products loaded successfully '
        'WHEN view is displayed '
        'THEN should display products in grid', (tester) async {
      await mockNetworkImagesFor(() async {
        final products = TestHelpers.createTestProductList(count: 4);
        when(() => mockApi.getProducts()).thenAnswer((_) async => products);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.byType(GridView), findsOneWidget);
        expect(find.text('Product 1'), findsOneWidget);
      });
    });

    testWidgets('GIVEN catalog view '
        'WHEN view is displayed '
        'THEN should display cart icon in app bar', (tester) async {
      when(() => mockApi.getProducts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('GIVEN cart has 2 items '
        'WHEN view is displayed '
        'THEN should display cart badge with quantity', (tester) async {
      when(() => mockApi.getProducts()).thenAnswer((_) async => []);
      cartStore.addProduct(TestHelpers.createTestProduct(id: 1));
      cartStore.addProduct(TestHelpers.createTestProduct(id: 1));

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('GIVEN cart is empty '
        'WHEN view is displayed '
        'THEN should not display cart badge', (tester) async {
      when(() => mockApi.getProducts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      final badgeText = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            int.tryParse(widget.data!) != null &&
            widget.style?.color == Colors.white,
      );
      expect(badgeText, findsNothing);
    });

    testWidgets('GIVEN catalog view '
        'WHEN cart icon is tapped '
        'THEN should navigate to cart', (tester) async {
      when(() => mockApi.getProducts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      expect(find.text('Cart Screen'), findsOneWidget);
    });
  });
}
