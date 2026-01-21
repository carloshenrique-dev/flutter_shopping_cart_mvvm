import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';

import 'package:flutter_shopping_cart_mvvm/features/cart/presentation/strings/cart_strings.dart';
import 'package:flutter_shopping_cart_mvvm/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:flutter_shopping_cart_mvvm/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:flutter_shopping_cart_mvvm/features/core/presentation/viewmodels/cart_store.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late CartStore cartStore;
  late MockCartApi mockCartApi;
  late CartViewModel cartViewModel;

  setUpAll(() {
    registerFallbackValue(FakeCartItem());
  });

  setUp(() {
    cartStore = CartStore();
    mockCartApi = MockCartApi();
    cartViewModel = CartViewModel(cartStore: cartStore, api: mockCartApi);
  });

  Widget createWidget(item, {bool isRemoving = false}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartStore>.value(value: cartStore),
        ChangeNotifierProvider<CartViewModel>.value(value: cartViewModel),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: CartItemCard(item: item, isRemoving: isRemoving),
        ),
      ),
    );
  }

  group('CartItemCard', () {
    testWidgets('GIVEN a cart item with product '
        'WHEN card is displayed '
        'THEN should display product title', (tester) async {
      await mockNetworkImagesFor(() async {
        final item = TestHelpers.createTestCartItem(
          product: TestHelpers.createTestProduct(title: 'Test Product Title'),
        );

        await tester.pumpWidget(createWidget(item));

        expect(find.text('Test Product Title'), findsOneWidget);
      });
    });

    testWidgets('GIVEN a cart item with price '
        'WHEN card is displayed '
        'THEN should display product price', (tester) async {
      await mockNetworkImagesFor(() async {
        final item = TestHelpers.createTestCartItem(
          product: TestHelpers.createTestProduct(price: 19.99),
        );

        await tester.pumpWidget(createWidget(item));

        expect(find.text(CartStrings.priceFormat(19.99)), findsOneWidget);
      });
    });

    testWidgets('GIVEN a cart item with quantity '
        'WHEN card is displayed '
        'THEN should display item subtotal', (tester) async {
      await mockNetworkImagesFor(() async {
        final item = TestHelpers.createTestCartItem(
          product: TestHelpers.createTestProduct(price: 10.00),
          quantity: 3,
        );

        await tester.pumpWidget(createWidget(item));

        expect(find.text(CartStrings.subtotalFormat(30.00)), findsOneWidget);
      });
    });

    testWidgets('GIVEN a cart item with quantity 5 '
        'WHEN card is displayed '
        'THEN should display item quantity', (tester) async {
      await mockNetworkImagesFor(() async {
        final item = TestHelpers.createTestCartItem(quantity: 5);

        await tester.pumpWidget(createWidget(item));

        expect(find.text('5'), findsOneWidget);
      });
    });

    testWidgets('GIVEN a cart item '
        'WHEN card is displayed '
        'THEN should display quantity control buttons', (tester) async {
      await mockNetworkImagesFor(() async {
        final item = TestHelpers.createTestCartItem();

        await tester.pumpWidget(createWidget(item));

        expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      });
    });

    testWidgets('GIVEN a cart item '
        'WHEN card is displayed '
        'THEN should display remove button', (tester) async {
      await mockNetworkImagesFor(() async {
        final item = TestHelpers.createTestCartItem();

        await tester.pumpWidget(createWidget(item));

        expect(find.text(CartStrings.removeButton), findsOneWidget);
      });
    });

    testWidgets('GIVEN a cart item in cart '
        'WHEN plus button is pressed '
        'THEN should increment quantity', (tester) async {
      await mockNetworkImagesFor(() async {
        final product = TestHelpers.createTestProduct();
        cartStore.addProduct(product);
        final item = cartStore.cart.items.first;

        await tester.pumpWidget(createWidget(item));
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pump();

        expect(cartStore.cart.items.first.quantity, 2);
      });
    });

    testWidgets('GIVEN a cart item with quantity 2 '
        'WHEN minus button is pressed '
        'THEN should decrement quantity', (tester) async {
      await mockNetworkImagesFor(() async {
        final product = TestHelpers.createTestProduct();
        cartStore.addProduct(product);
        cartStore.addProduct(product);
        final item = cartStore.cart.items.first;

        await tester.pumpWidget(createWidget(item));
        await tester.tap(find.byIcon(Icons.remove_circle_outline));
        await tester.pump();

        expect(cartStore.cart.items.first.quantity, 1);
      });
    });

    testWidgets('GIVEN isRemoving is true '
        'WHEN card is displayed '
        'THEN should show loading spinner', (tester) async {
      await mockNetworkImagesFor(() async {
        final item = TestHelpers.createTestCartItem();

        await tester.pumpWidget(createWidget(item, isRemoving: true));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    testWidgets('GIVEN isRemoving is true '
        'WHEN card is displayed '
        'THEN should disable remove button', (tester) async {
      await mockNetworkImagesFor(() async {
        final item = TestHelpers.createTestCartItem();

        await tester.pumpWidget(createWidget(item, isRemoving: true));

        final removeText = find.text(CartStrings.removeButton);
        expect(removeText, findsOneWidget);

        final textWidget = tester.widget<Text>(removeText);
        expect(textWidget.style?.color, Colors.grey);
      });
    });

    testWidgets('GIVEN a cart item '
        'WHEN remove button is pressed '
        'THEN should call removeItem', (tester) async {
      await mockNetworkImagesFor(() async {
        final product = TestHelpers.createTestProduct();
        cartStore.addProduct(product);
        final item = cartStore.cart.items.first;

        when(() => mockCartApi.removeItem(any())).thenAnswer((_) async {});

        await tester.pumpWidget(createWidget(item));
        await tester.tap(find.text(CartStrings.removeButton));
        await tester.pumpAndSettle();

        verify(() => mockCartApi.removeItem(any())).called(1);
      });
    });

    testWidgets('GIVEN a cart item with image '
        'WHEN card is displayed '
        'THEN should display product image', (tester) async {
      await mockNetworkImagesFor(() async {
        final item = TestHelpers.createTestCartItem(
          product: TestHelpers.createTestProduct(
            image: 'https://example.com/image.png',
          ),
        );

        await tester.pumpWidget(createWidget(item));

        expect(find.byType(Image), findsOneWidget);
      });
    });
  });
}
