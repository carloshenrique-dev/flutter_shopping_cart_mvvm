import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_shopping_cart_mvvm/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:flutter_shopping_cart_mvvm/features/core/presentation/viewmodels/cart_store.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late MockCartApi mockApi;
  late CartStore cartStore;
  late CartViewModel viewModel;
  final item = TestHelpers.createTestCartItem();

  setUpAll(() {
    registerFallbackValue(FakeCartItem());
  });

  setUp(() {
    mockApi = MockCartApi();
    cartStore = CartStore();
    viewModel = CartViewModel(cartStore: cartStore, api: mockApi);
  });

  group('CartViewModel', () {
    group('initial state', () {
      test('GIVEN a new CartViewModel instance '
          'WHEN it is created '
          'THEN should have correct initial state', () {
        expect(viewModel.isRemoving, isFalse);
        expect(viewModel.errorMessage, isNull);
      });
    });

    group('removeItem', () {
      test('GIVEN an item to remove '
          'WHEN removeItem is called '
          'THEN should set isRemoving to true while removing', () async {
        when(
          () => mockApi.removeItem(any()),
        ).thenAnswer((_) => Future.delayed(const Duration(milliseconds: 100)));

        final future = viewModel.removeItem(item);

        expect(viewModel.isRemoving, isTrue);

        await future;
      });

      test('GIVEN an item in the cart '
          'WHEN removeItem completes successfully '
          'THEN should set isRemoving to false', () async {
        final product = TestHelpers.createTestProduct();
        cartStore.addProduct(product);
        final item = cartStore.cart.items.first;

        when(() => mockApi.removeItem(any())).thenAnswer((_) async {});

        await viewModel.removeItem(item);

        expect(viewModel.isRemoving, isFalse);
      });

      test('GIVEN an item in the cart '
          'WHEN removeItem completes successfully '
          'THEN should remove item from cart store', () async {
        final product = TestHelpers.createTestProduct();
        cartStore.addProduct(product);
        final item = cartStore.cart.items.first;

        when(() => mockApi.removeItem(any())).thenAnswer((_) async {});

        await viewModel.removeItem(item);

        expect(cartStore.cart.items, isEmpty);
      });

      test('GIVEN an item to remove '
          'WHEN api throws an exception '
          'THEN should set error message', () async {
        when(
          () => mockApi.removeItem(any()),
        ).thenThrow(Exception('Failed to remove item. Please try again.'));

        await viewModel.removeItem(item);

        expect(
          viewModel.errorMessage,
          'Failed to remove item. Please try again.',
        );
        expect(viewModel.isRemoving, isFalse);
      });

      test('GIVEN an item in the cart '
          'WHEN api throws an exception '
          'THEN should not remove item from cart store', () async {
        final product = TestHelpers.createTestProduct();
        cartStore.addProduct(product);
        final item = cartStore.cart.items.first;

        when(
          () => mockApi.removeItem(any()),
        ).thenThrow(Exception('Failed to remove'));

        await viewModel.removeItem(item);

        expect(cartStore.cart.items.length, 1);
      });

      test('GIVEN a previous error exists '
          'WHEN removeItem is called again '
          'THEN should clear previous error before removing', () async {
        when(
          () => mockApi.removeItem(any()),
        ).thenThrow(Exception('First error'));
        await viewModel.removeItem(item);

        expect(viewModel.errorMessage, 'First error');

        when(() => mockApi.removeItem(any())).thenAnswer((_) async {});
        await viewModel.removeItem(item);

        expect(viewModel.errorMessage, isNull);
      });

      test('GIVEN an item to remove '
          'WHEN removeItem is called '
          'THEN should notify listeners during removal process', () async {
        when(() => mockApi.removeItem(any())).thenAnswer((_) async {});

        var notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        await viewModel.removeItem(item);

        expect(notifyCount, 2);
      });
    });

    group('updateQuantity', () {
      test('GIVEN an item in the cart '
          'WHEN updateQuantity completes successfully '
          'THEN should update quantity in cart store', () async {
        final product = TestHelpers.createTestProduct();
        cartStore.addProduct(product);
        final item = cartStore.cart.items.first;

        when(
          () => mockApi.updateQuantity(any(), any()),
        ).thenAnswer((_) async {});

        await viewModel.updateQuantity(item, 5);

        expect(cartStore.cart.items.first.quantity, 5);
      });

      test('GIVEN an item to update '
          'WHEN api throws an exception '
          'THEN should set error message', () async {
        when(
          () => mockApi.updateQuantity(any(), any()),
        ).thenThrow(Exception('Failed to update'));

        await viewModel.updateQuantity(item, 5);

        expect(viewModel.errorMessage, 'Failed to update quantity');
      });

      test('GIVEN an item in the cart '
          'WHEN api throws an exception '
          'THEN should not update cart store', () async {
        final product = TestHelpers.createTestProduct();
        cartStore.addProduct(product);
        final item = cartStore.cart.items.first;

        when(
          () => mockApi.updateQuantity(any(), any()),
        ).thenThrow(Exception('Network error'));

        await viewModel.updateQuantity(item, 5);

        expect(cartStore.cart.items.first.quantity, 1);
      });

      test('GIVEN an item and a new quantity '
          'WHEN updateQuantity is called '
          'THEN should call api with correct parameters', () async {
        final product = TestHelpers.createTestProduct();
        cartStore.addProduct(product);
        final item = cartStore.cart.items.first;

        when(
          () => mockApi.updateQuantity(any(), any()),
        ).thenAnswer((_) async {});

        await viewModel.updateQuantity(item, 5);

        verify(() => mockApi.updateQuantity(item, 5)).called(1);
      });
    });

    group('clearError', () {
      test('GIVEN an error message exists '
          'WHEN clearError is called '
          'THEN should clear error message', () async {
        when(
          () => mockApi.removeItem(any()),
        ).thenThrow(Exception('Test error'));

        await viewModel.removeItem(item);
        expect(viewModel.errorMessage, 'Test error');

        viewModel.clearError();

        expect(viewModel.errorMessage, isNull);
      });

      test('GIVEN an error message exists '
          'WHEN clearError is called '
          'THEN should notify listeners', () async {
        when(
          () => mockApi.removeItem(any()),
        ).thenThrow(Exception('Test error'));

        await viewModel.removeItem(item);

        var notified = false;
        viewModel.addListener(() => notified = true);

        viewModel.clearError();

        expect(notified, isTrue);
      });
    });
  });
}
