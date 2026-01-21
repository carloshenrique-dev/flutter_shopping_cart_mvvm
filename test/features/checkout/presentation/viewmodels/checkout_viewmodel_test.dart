import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_shopping_cart_mvvm/features/core/domain/models/checkout_state.dart';
import 'package:flutter_shopping_cart_mvvm/features/checkout/presentation/viewmodels/checkout_viewmodel.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late MockCheckoutApi mockApi;
  late CheckoutViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeCart());
  });

  setUp(() {
    mockApi = MockCheckoutApi();
    viewModel = CheckoutViewModel(api: mockApi);
  });

  group('CheckoutViewModel', () {
    group('initial state', () {
      test('GIVEN a new CheckoutViewModel '
          'WHEN instantiated '
          'THEN should have correct initial state', () {
        expect(viewModel.state, CheckoutState.initial);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.result, isNull);
        expect(viewModel.orderItems, isEmpty);
        expect(viewModel.subtotal, 0.0);
      });
    });

    group('processCheckout', () {
      test('GIVEN a valid cart '
          'WHEN processCheckout succeeds '
          'THEN should emit processing state then success state', () async {
        final cart = TestHelpers.createTestCart(
          items: [
            TestHelpers.createTestCartItem(
              product: TestHelpers.createTestProduct(price: 10.0),
              quantity: 2,
            ),
          ],
        );
        final result = TestHelpers.createTestCheckoutResult(total: 25.99);

        when(() => mockApi.checkout(any())).thenAnswer((_) async => result);

        final states = <CheckoutState>[];
        viewModel.addListener(() => states.add(viewModel.state));

        await viewModel.processCheckout(cart);

        expect(states, [CheckoutState.processing, CheckoutState.success]);
        expect(viewModel.result, result);
      });

      test('GIVEN a valid cart '
          'WHEN processCheckout fails '
          'THEN should emit processing state then error state', () async {
        final cart = TestHelpers.createTestCart();
        when(
          () => mockApi.checkout(any()),
        ).thenThrow(Exception('Network error'));

        final states = <CheckoutState>[];
        viewModel.addListener(() => states.add(viewModel.state));

        await viewModel.processCheckout(cart);

        expect(states, [CheckoutState.processing, CheckoutState.error]);
        expect(
          viewModel.errorMessage,
          'Failed to process checkout. Please try again.',
        );
      });

      test('GIVEN a cart with items '
          'WHEN processCheckout is called '
          'THEN should store order items from cart', () async {
        final items = [
          TestHelpers.createTestCartItem(
            product: TestHelpers.createTestProduct(id: 1),
            quantity: 2,
          ),
          TestHelpers.createTestCartItem(
            product: TestHelpers.createTestProduct(id: 2),
            quantity: 1,
          ),
        ];
        final cart = TestHelpers.createTestCart(items: items);
        final result = TestHelpers.createTestCheckoutResult();
        when(() => mockApi.checkout(any())).thenAnswer((_) async => result);

        await viewModel.processCheckout(cart);

        expect(viewModel.orderItems.length, 2);
      });

      test('GIVEN a cart with items of different prices '
          'WHEN processCheckout is called '
          'THEN should calculate correct subtotal from order items', () async {
        final items = [
          TestHelpers.createTestCartItem(
            product: TestHelpers.createTestProduct(price: 10.0),
            quantity: 2,
          ),
          TestHelpers.createTestCartItem(
            product: TestHelpers.createTestProduct(id: 2, price: 20.0),
            quantity: 1,
          ),
        ];
        final cart = TestHelpers.createTestCart(items: items);
        final result = TestHelpers.createTestCheckoutResult();

        when(() => mockApi.checkout(any())).thenAnswer((_) async => result);

        await viewModel.processCheckout(cart);

        expect(viewModel.subtotal, 40.0);
      });

      test('GIVEN a cart '
          'WHEN processCheckout is called '
          'THEN should notify listeners on state changes', () async {
        final cart = TestHelpers.createTestCart();
        when(
          () => mockApi.checkout(any()),
        ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

        var notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        await viewModel.processCheckout(cart);

        expect(notifyCount, 2);
      });

      test('GIVEN a cart '
          'WHEN processCheckout is called '
          'THEN should call api checkout with cart', () async {
        final cart = TestHelpers.createTestCart();
        when(
          () => mockApi.checkout(any()),
        ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

        await viewModel.processCheckout(cart);

        verify(() => mockApi.checkout(cart)).called(1);
      });
    });

    group('reset', () {
      test('GIVEN a viewModel in success state '
          'WHEN reset is called '
          'THEN should reset all state to initial values', () async {
        final cart = TestHelpers.createTestCart(
          items: [TestHelpers.createTestCartItem()],
        );
        when(
          () => mockApi.checkout(any()),
        ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

        await viewModel.processCheckout(cart);

        expect(viewModel.state, CheckoutState.success);
        expect(viewModel.result, isNotNull);

        viewModel.reset();

        expect(viewModel.state, CheckoutState.initial);
        expect(viewModel.errorMessage, isNull);
        expect(viewModel.result, isNull);
        expect(viewModel.orderItems, isEmpty);
      });

      test('GIVEN a viewModel '
          'WHEN reset is called '
          'THEN should notify listeners', () async {
        var notified = false;
        viewModel.addListener(() => notified = true);

        viewModel.reset();

        expect(notified, isTrue);
      });
    });

    group('subtotal calculation', () {
      test('GIVEN order items is empty '
          'WHEN subtotal is accessed '
          'THEN should return 0', () {
        expect(viewModel.subtotal, 0.0);
      });

      test('GIVEN a cart with items '
          'WHEN checkout is processed '
          'THEN should calculate subtotal correctly', () async {
        final items = [
          TestHelpers.createTestCartItem(
            product: TestHelpers.createTestProduct(price: 15.50),
            quantity: 2,
          ),
          TestHelpers.createTestCartItem(
            product: TestHelpers.createTestProduct(id: 2, price: 25.00),
            quantity: 3,
          ),
        ];
        final cart = TestHelpers.createTestCart(items: items);

        when(
          () => mockApi.checkout(any()),
        ).thenAnswer((_) async => TestHelpers.createTestCheckoutResult());

        await viewModel.processCheckout(cart);

        expect(viewModel.subtotal, 106.0);
      });
    });
  });
}
