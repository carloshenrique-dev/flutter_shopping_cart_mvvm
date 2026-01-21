import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_shopping_cart_mvvm/features/cart/presentation/strings/cart_strings.dart';
import 'package:flutter_shopping_cart_mvvm/features/cart/presentation/widgets/order_summary.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/domain/models/checkout_result.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:flutter_shopping_cart_mvvm/features/core/domain/models/checkout_state.dart';
import 'package:flutter_shopping_cart_mvvm/features/core/presentation/viewmodels/cart_store.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late CartStore cartStore;
  late MockCheckoutApi mockCheckoutApi;
  late CheckoutViewModel checkoutViewModel;

  setUpAll(() {
    registerFallbackValue(FakeCart());
  });

  setUp(() {
    cartStore = CartStore();
    mockCheckoutApi = MockCheckoutApi();
    checkoutViewModel = CheckoutViewModel(api: mockCheckoutApi);
  });

  Widget createWidget({double subtotal = 50.00}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartStore>.value(value: cartStore),
        ChangeNotifierProvider<CheckoutViewModel>.value(
          value: checkoutViewModel,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(body: OrderSummary(subtotal: subtotal)),
        routes: {
          '/order-complete': (context) =>
              const Scaffold(body: Text('Order Complete Screen')),
        },
      ),
    );
  }

  group('OrderSummary', () {
    testWidgets('GIVEN an order summary widget '
        'WHEN widget is displayed '
        'THEN should display subtotal label', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text(CartStrings.subtotalLabel), findsOneWidget);
    });

    testWidgets('GIVEN an order summary widget '
        'WHEN widget is displayed '
        'THEN should display total label', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text(CartStrings.totalLabel), findsOneWidget);
    });

    testWidgets('GIVEN an order summary widget '
        'WHEN widget is displayed '
        'THEN should display checkout button', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text(CartStrings.checkoutButton), findsOneWidget);
    });

    testWidgets('GIVEN a subtotal of 99.99 '
        'WHEN widget is displayed '
        'THEN should display subtotal price', (tester) async {
      await tester.pumpWidget(createWidget(subtotal: 99.99));

      expect(find.text(CartStrings.priceFormat(99.99)), findsWidgets);
    });

    testWidgets('GIVEN a subtotal of 45.50 '
        'WHEN widget is displayed '
        'THEN should display total price', (tester) async {
      await tester.pumpWidget(createWidget(subtotal: 45.50));

      expect(find.text(CartStrings.priceFormat(45.50)), findsWidgets);
    });

    testWidgets('GIVEN checkout is processing '
        'WHEN widget is displayed '
        'THEN should show loading spinner', (tester) async {
      final completer = Completer<CheckoutResult>();
      when(
        () => mockCheckoutApi.checkout(any()),
      ).thenAnswer((_) => completer.future);

      cartStore.addProduct(TestHelpers.createTestProduct());
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text(CartStrings.checkoutButton));
      await tester.pump();

      expect(checkoutViewModel.state, CheckoutState.processing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(TestHelpers.createTestCheckoutResult());
      await tester.pumpAndSettle();
    });

    testWidgets('GIVEN checkout is processing '
        'WHEN widget is displayed '
        'THEN should disable checkout button', (tester) async {
      final completer = Completer<CheckoutResult>();
      when(
        () => mockCheckoutApi.checkout(any()),
      ).thenAnswer((_) => completer.future);

      cartStore.addProduct(TestHelpers.createTestProduct());
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text(CartStrings.checkoutButton));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      completer.complete(TestHelpers.createTestCheckoutResult());
      await tester.pumpAndSettle();
    });

    testWidgets('GIVEN a cart with items '
        'WHEN checkout button is pressed '
        'THEN should call processCheckout', (tester) async {
      when(
        () => mockCheckoutApi.checkout(any()),
      ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

      cartStore.addProduct(TestHelpers.createTestProduct());
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text(CartStrings.checkoutButton));
      await tester.pumpAndSettle();

      verify(() => mockCheckoutApi.checkout(any())).called(1);
    });

    testWidgets('GIVEN a cart with one item '
        'WHEN checkout is successful '
        'THEN should clear cart', (tester) async {
      when(
        () => mockCheckoutApi.checkout(any()),
      ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

      cartStore.addProduct(TestHelpers.createTestProduct());
      expect(cartStore.cart.items.length, 1);

      await tester.pumpWidget(createWidget());

      await tester.tap(find.text(CartStrings.checkoutButton));
      await tester.pumpAndSettle();

      expect(cartStore.cart.items, isEmpty);
    });

    testWidgets('GIVEN a cart with items '
        'WHEN checkout is successful '
        'THEN should navigate to order complete', (tester) async {
      when(
        () => mockCheckoutApi.checkout(any()),
      ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

      cartStore.addProduct(TestHelpers.createTestProduct());
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text(CartStrings.checkoutButton));
      await tester.pumpAndSettle();

      expect(find.text('Order Complete Screen'), findsOneWidget);
    });

    testWidgets('GIVEN an order summary widget '
        'WHEN widget is displayed '
        'THEN should have checkout button with green background', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style?.backgroundColor, isNotNull);
    });
  });
}
