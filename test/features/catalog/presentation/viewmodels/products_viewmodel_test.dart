import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_shopping_cart_mvvm/features/catalog/presentation/viewmodels/products_viewmodel.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late MockProductsApi mockApi;
  late ProductsViewModel viewModel;

  setUp(() {
    mockApi = MockProductsApi();
    viewModel = ProductsViewModel(api: mockApi);
  });

  group('ProductsViewModel', () {
    group('initial state', () {
      test('GIVEN a new ProductsViewModel instance '
          'WHEN it is created '
          'THEN should have initial state', () {
        expect(viewModel.state, ViewState.initial);
        expect(viewModel.products, isEmpty);
        expect(viewModel.errorMessage, isEmpty);
      });
    });

    group('loadProducts', () {
      test('GIVEN api returns products successfully '
          'WHEN loadProducts is called '
          'THEN should emit loading state then loaded state', () async {
        final products = TestHelpers.createTestProductList(count: 3);
        when(() => mockApi.getProducts()).thenAnswer((_) async => products);

        final states = <ViewState>[];
        viewModel.addListener(() => states.add(viewModel.state));

        await viewModel.loadProducts();

        expect(states, [ViewState.loading, ViewState.loaded]);
        expect(viewModel.products, products);
      });

      test('GIVEN api throws an exception '
          'WHEN loadProducts is called '
          'THEN should emit loading state then error state', () async {
        when(() => mockApi.getProducts()).thenThrow(Exception('Network error'));

        final states = <ViewState>[];
        viewModel.addListener(() => states.add(viewModel.state));

        await viewModel.loadProducts();

        expect(states, [ViewState.loading, ViewState.error]);
        expect(
          viewModel.errorMessage,
          'Failed to load products. Please try again.',
        );
      });

      test('GIVEN products were previously loaded '
          'WHEN loadProducts is called again '
          'THEN should clear previous products on new load', () async {
        final products1 = TestHelpers.createTestProductList(count: 2);
        final products2 = TestHelpers.createTestProductList(count: 3);

        when(() => mockApi.getProducts()).thenAnswer((_) async => products1);
        await viewModel.loadProducts();
        expect(viewModel.products.length, 2);

        when(() => mockApi.getProducts()).thenAnswer((_) async => products2);
        await viewModel.loadProducts();
        expect(viewModel.products.length, 3);
      });

      test('GIVEN viewModel has listeners '
          'WHEN loadProducts is called '
          'THEN should notify listeners on state changes', () async {
        when(() => mockApi.getProducts()).thenAnswer((_) async => []);

        var notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        await viewModel.loadProducts();

        expect(notifyCount, 2);
      });

      test('GIVEN api returns empty list '
          'WHEN loadProducts is called '
          'THEN should handle empty product list', () async {
        when(() => mockApi.getProducts()).thenAnswer((_) async => []);

        await viewModel.loadProducts();

        expect(viewModel.state, ViewState.loaded);
        expect(viewModel.products, isEmpty);
      });

      test('GIVEN viewModel is ready '
          'WHEN loadProducts is called '
          'THEN should call api getProducts', () async {
        when(() => mockApi.getProducts()).thenAnswer((_) async => []);

        await viewModel.loadProducts();

        verify(() => mockApi.getProducts()).called(1);
      });
    });
  });
}
