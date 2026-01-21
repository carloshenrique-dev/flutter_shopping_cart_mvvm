import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import 'package:flutter_shopping_cart_mvvm/features/cart/presentation/strings/cart_strings.dart';
import 'package:flutter_shopping_cart_mvvm/features/cart/presentation/views/cart_view.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:flutter_shopping_cart_mvvm/features/core/presentation/viewmodels/cart_store.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late CartStore cartStore;
  late CheckoutViewModel checkoutViewModel;

  setUpAll(() {
    registerFallbackValue(FakeCartItem());
    registerFallbackValue(FakeCart());
  });

  setUp(() {
    cartStore = CartStore();
    checkoutViewModel = CheckoutViewModel();
  });

  Widget createWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartStore>.value(value: cartStore),
        ChangeNotifierProvider<CheckoutViewModel>.value(
          value: checkoutViewModel,
        ),
      ],
      child: MaterialApp(
        home: const CartView(),
        routes: {
          '/order-complete': (context) =>
              const Scaffold(body: Text('Order Complete Screen')),
        },
      ),
    );
  }

  group('CartView', () {
    testWidgets('GIVEN CartView is rendered '
        'WHEN view is displayed '
        'THEN should display app bar with title', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text(CartStrings.appBarTitle), findsOneWidget);
    });

    testWidgets('GIVEN cart is empty '
        'WHEN view is displayed '
        'THEN should display empty cart message', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text(CartStrings.emptyCartMessage), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('GIVEN cart has items '
        'WHEN view is displayed '
        'THEN should display cart items', (tester) async {
      await mockNetworkImagesFor(() async {
        final product = TestHelpers.createTestProduct(title: 'Test Item');
        cartStore.addProduct(product);

        await tester.pumpWidget(createWidget());

        expect(find.text('Test Item'), findsOneWidget);
      });
    });

    testWidgets('GIVEN cart has items '
        'WHEN view is displayed '
        'THEN should display order summary', (tester) async {
      await mockNetworkImagesFor(() async {
        cartStore.addProduct(TestHelpers.createTestProduct(price: 25.00));

        await tester.pumpWidget(createWidget());

        expect(find.text(CartStrings.subtotalLabel), findsOneWidget);
        expect(find.text(CartStrings.totalLabel), findsOneWidget);
        expect(find.text(CartStrings.checkoutButton), findsOneWidget);
      });
    });

    testWidgets('GIVEN cart has multiple items '
        'WHEN view is displayed '
        'THEN should display all cart items', (tester) async {
      await mockNetworkImagesFor(() async {
        cartStore.addProduct(
          TestHelpers.createTestProduct(id: 1, title: 'Item 1'),
        );
        cartStore.addProduct(
          TestHelpers.createTestProduct(id: 2, title: 'Item 2'),
        );

        await tester.pumpWidget(createWidget());

        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
      });
    });

    testWidgets('GIVEN cart has items with prices '
        'WHEN view is displayed '
        'THEN should display correct subtotal in order summary', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        cartStore.addProduct(TestHelpers.createTestProduct(price: 10.00));
        cartStore.addProduct(TestHelpers.createTestProduct(price: 10.00));

        await tester.pumpWidget(createWidget());

        expect(find.text(CartStrings.priceFormat(20.00)), findsWidgets);
      });
    });

    testWidgets('GIVEN a product in cart '
        'WHEN product quantity changes '
        'THEN should update UI', (tester) async {
      await mockNetworkImagesFor(() async {
        final product = TestHelpers.createTestProduct();
        cartStore.addProduct(product);

        await tester.pumpWidget(createWidget());

        expect(find.text('1'), findsOneWidget);

        cartStore.addProduct(product);
        await tester.pump();

        expect(find.text('2'), findsOneWidget);
      });
    });

    testWidgets('GIVEN cart has one item '
        'WHEN last item is removed '
        'THEN should show empty state', (tester) async {
      await mockNetworkImagesFor(() async {
        final product = TestHelpers.createTestProduct();
        cartStore.addProduct(product);

        await tester.pumpWidget(createWidget());
        expect(find.text(CartStrings.emptyCartMessage), findsNothing);

        cartStore.clearCart();
        await tester.pump();

        expect(find.text(CartStrings.emptyCartMessage), findsOneWidget);
      });
    });
  });
}
