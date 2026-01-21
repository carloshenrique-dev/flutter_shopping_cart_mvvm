import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_shopping_cart_mvvm/features/checkout/presentation/strings/checkout_strings.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/presentation/widgets/order_summary_footer.dart';

void main() {
  Widget createWidget({
    double subtotal = 40.00,
    double shipping = 5.99,
    double total = 45.99,
    VoidCallback? onNewOrder,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OrderSummaryFooter(
          subtotal: subtotal,
          shipping: shipping,
          total: total,
          onNewOrder: onNewOrder ?? () {},
        ),
      ),
    );
  }

  group('OrderSummaryFooter', () {
    testWidgets('GIVEN an order summary footer '
        'WHEN widget is displayed '
        'THEN should display subtotal label', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text(CheckoutStrings.subtotalLabel), findsOneWidget);
    });

    testWidgets('GIVEN an order summary footer '
        'WHEN widget is displayed '
        'THEN should display shipping label', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text(CheckoutStrings.shippingLabel), findsOneWidget);
    });

    testWidgets('GIVEN an order summary footer '
        'WHEN widget is displayed '
        'THEN should display total label', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text(CheckoutStrings.totalLabel), findsOneWidget);
    });

    testWidgets('GIVEN an order summary footer '
        'WHEN widget is displayed '
        'THEN should display new order button', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text(CheckoutStrings.newOrderButton), findsOneWidget);
    });

    testWidgets('GIVEN subtotal of 100.00 '
        'WHEN widget is displayed '
        'THEN should display subtotal price', (tester) async {
      await tester.pumpWidget(createWidget(subtotal: 100.00));

      expect(find.text(CheckoutStrings.priceFormat(100.00)), findsOneWidget);
    });

    testWidgets('GIVEN shipping of 9.99 '
        'WHEN widget is displayed '
        'THEN should display shipping price', (tester) async {
      await tester.pumpWidget(createWidget(shipping: 9.99));

      expect(find.text(CheckoutStrings.priceFormat(9.99)), findsOneWidget);
    });

    testWidgets('GIVEN total of 150.00 '
        'WHEN widget is displayed '
        'THEN should display total price', (tester) async {
      await tester.pumpWidget(createWidget(total: 150.00));

      expect(find.text(CheckoutStrings.priceFormat(150.00)), findsOneWidget);
    });

    testWidgets('GIVEN an onNewOrder callback '
        'WHEN new order button is pressed '
        'THEN should call onNewOrder', (tester) async {
      var called = false;
      await tester.pumpWidget(createWidget(onNewOrder: () => called = true));

      await tester.tap(find.text(CheckoutStrings.newOrderButton));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('GIVEN an order summary footer '
        'WHEN widget is displayed '
        'THEN should have new order button with green background', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style?.backgroundColor, isNotNull);
    });

    testWidgets('GIVEN total of 99.99 '
        'WHEN widget is displayed '
        'THEN should display total in bold', (tester) async {
      await tester.pumpWidget(createWidget(total: 99.99));

      final totalPriceText = find.text(CheckoutStrings.priceFormat(99.99));
      expect(totalPriceText, findsOneWidget);

      final textWidget = tester.widget<Text>(totalPriceText);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('GIVEN an order summary footer '
        'WHEN widget is displayed '
        'THEN should display divider between shipping and total', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
