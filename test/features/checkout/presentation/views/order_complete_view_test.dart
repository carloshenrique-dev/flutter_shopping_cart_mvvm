import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import 'package:flutter_shopping_cart_mvvm/features/core/domain/models/checkout_state.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/presentation/strings/checkout_strings.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/presentation/views/order_complete_view.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late MockCheckoutApi mockCheckoutApi;
  late CheckoutViewModel checkoutViewModel;
  final cart = TestHelpers.createTestCart(
    items: [TestHelpers.createTestCartItem()],
  );

  setUpAll(() {
    registerFallbackValue(FakeCart());
  });

  setUp(() {
    mockCheckoutApi = MockCheckoutApi();
    checkoutViewModel = CheckoutViewModel(api: mockCheckoutApi);
  });

  Widget createWidget() {
    return ChangeNotifierProvider<CheckoutViewModel>.value(
      value: checkoutViewModel,
      child: MaterialApp(
        routes: {
          '/': (context) => const Scaffold(body: Text('Catalog Screen')),
          '/order-complete': (context) => const OrderCompleteView(),
        },
        initialRoute: '/order-complete',
      ),
    );
  }

  group('OrderCompleteView', () {
    testWidgets('GIVEN result is null '
        'WHEN view is rendered'
        ' THEN should display no order data message', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text(CheckoutStrings.noOrderDataMessage), findsOneWidget);
      });
    });

    testWidgets('GIVEN checkout is successful'
        'WHEN view is rendered'
        'THEN should display thank you message', (tester) async {
      await mockNetworkImagesFor(() async {
        final cart = TestHelpers.createTestCart(
          items: [
            TestHelpers.createTestCartItem(
              product: TestHelpers.createTestProduct(
                id: 1,
                title: 'Product 1',
                price: 10.00,
              ),
              quantity: 2,
            ),
          ],
        );

        when(() => mockCheckoutApi.checkout(any())).thenAnswer(
          (_) async => TestHelpers.createTestCheckoutResult(
            orderId: 'ORD-TEST-123',
            shipping: 5.99,
            total: 25.99,
          ),
        );

        await checkoutViewModel.processCheckout(cart);
        expect(checkoutViewModel.state, CheckoutState.success);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text(CheckoutStrings.thankYouMessage), findsOneWidget);
      });
    });

    testWidgets('GIVEN checkout is successful'
        'WHEN view is rendered'
        'THEN should display success icon', (tester) async {
      await mockNetworkImagesFor(() async {
        when(
          () => mockCheckoutApi.checkout(any()),
        ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

        await checkoutViewModel.processCheckout(cart);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });
    });

    testWidgets('GIVEN checkout is successful with order id ORD-TEST-456'
        'WHEN view is rendered'
        'THEN should display order id', (tester) async {
      await mockNetworkImagesFor(() async {
        when(() => mockCheckoutApi.checkout(any())).thenAnswer(
          (_) async =>
              TestHelpers.createTestCheckoutResult(orderId: 'ORD-TEST-456'),
        );

        await checkoutViewModel.processCheckout(cart);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(
          find.text(CheckoutStrings.orderIdFormat('ORD-TEST-456')),
          findsOneWidget,
        );
      });
    });

    testWidgets('GIVEN checkout is successful'
        'WHEN view is rendered'
        'THEN should display order items title', (tester) async {
      await mockNetworkImagesFor(() async {
        when(
          () => mockCheckoutApi.checkout(any()),
        ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

        await checkoutViewModel.processCheckout(cart);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text(CheckoutStrings.orderItemsTitle), findsOneWidget);
      });
    });

    testWidgets('GIVEN checkout is successful'
        'WHEN view is rendered'
        'THEN should display new order button', (tester) async {
      await mockNetworkImagesFor(() async {
        when(
          () => mockCheckoutApi.checkout(any()),
        ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

        await checkoutViewModel.processCheckout(cart);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text(CheckoutStrings.newOrderButton), findsOneWidget);
      });
    });

    testWidgets('GIVEN checkout is successful'
        'WHEN view is rendered'
        'THEN should display footer labels', (tester) async {
      await mockNetworkImagesFor(() async {
        when(() => mockCheckoutApi.checkout(any())).thenAnswer(
          (_) async => TestHelpers.createTestCheckoutResult(
            shipping: 5.99,
            total: 15.99,
          ),
        );

        await checkoutViewModel.processCheckout(cart);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        expect(find.text(CheckoutStrings.subtotalLabel), findsOneWidget);
        expect(find.text(CheckoutStrings.shippingLabel), findsOneWidget);
        expect(find.text(CheckoutStrings.totalLabel), findsOneWidget);
      });
    });

    testWidgets('GIVEN checkout is successful'
        'WHEN view is rendered'
        'THEN should display footer prices', (tester) async {
      await mockNetworkImagesFor(() async {
        when(
          () => mockCheckoutApi.checkout(any()),
        ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

        await checkoutViewModel.processCheckout(cart);
        expect(checkoutViewModel.result, isNotNull);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text(CheckoutStrings.newOrderButton));
        await tester.pumpAndSettle();

        expect(checkoutViewModel.result, isNull);
        expect(checkoutViewModel.orderItems, isEmpty);
      });
    });

    testWidgets('GIVEN checkout is successful'
        'WHEN new order button is pressed'
        'THEN should navigate to catalog', (tester) async {
      await mockNetworkImagesFor(() async {
        when(
          () => mockCheckoutApi.checkout(any()),
        ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

        await checkoutViewModel.processCheckout(cart);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text(CheckoutStrings.newOrderButton));
        await tester.pumpAndSettle();

        expect(find.text('Catalog Screen'), findsOneWidget);
      });
    });
  });
}
