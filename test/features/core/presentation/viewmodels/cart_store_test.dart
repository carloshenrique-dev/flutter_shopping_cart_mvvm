import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_shopping_cart_mvvm/features/core/presentation/viewmodels/cart_store.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late CartStore cartStore;
  final product = TestHelpers.createTestProduct();

  setUp(() {
    cartStore = CartStore();
  });

  group('CartStore', () {
    group('initial state', () {
      test('GIVEN a new CartStore '
          'WHEN instantiated '
          'THEN should have empty cart', () {
        expect(cartStore.cart.items, isEmpty);
        expect(cartStore.cart.totalQuantity, 0);
        expect(cartStore.cart.subtotal, 0.0);
        expect(cartStore.cart.itemCount, 0);
      });
    });

    group('canAddProduct', () {
      test('GIVEN cart is empty '
          'WHEN canAddProduct is called '
          'THEN should return true', () {
        expect(cartStore.canAddProduct(product), isTrue);
      });

      test('GIVEN product already exists in cart '
          'WHEN canAddProduct is called '
          'THEN should return true', () {
        cartStore.addProduct(product);

        expect(cartStore.canAddProduct(product), isTrue);
      });

      test('GIVEN cart has less than max products '
          'WHEN canAddProduct is called with new product '
          'THEN should return true', () {
        for (var i = 0; i < CartStore.maxDifferentProducts - 1; i++) {
          cartStore.addProduct(TestHelpers.createTestProduct(id: i));
        }

        final newProduct = TestHelpers.createTestProduct(id: 100);
        expect(cartStore.canAddProduct(newProduct), isTrue);
      });

      test('GIVEN cart is full with different products '
          'WHEN canAddProduct is called with new product '
          'THEN should return false', () {
        for (var i = 0; i < CartStore.maxDifferentProducts; i++) {
          cartStore.addProduct(TestHelpers.createTestProduct(id: i));
        }

        final newProduct = TestHelpers.createTestProduct(id: 100);
        expect(cartStore.canAddProduct(newProduct), isFalse);
      });
    });

    group('getQuantity', () {
      test('GIVEN product is not in cart '
          'WHEN getQuantity is called '
          'THEN should return 0', () {
        expect(cartStore.getQuantity(1), 0);
      });

      test('GIVEN product with quantity 3 is in cart '
          'WHEN getQuantity is called '
          'THEN should return correct quantity', () {
        final product = TestHelpers.createTestProduct(id: 1);
        cartStore.addProduct(product);
        cartStore.addProduct(product);
        cartStore.addProduct(product);

        expect(cartStore.getQuantity(1), 3);
      });
    });

    group('addProduct', () {
      test('GIVEN an empty cart '
          'WHEN addProduct is called '
          'THEN should add new product to cart', () {
        cartStore.addProduct(product);

        expect(cartStore.cart.items.length, 1);
        expect(cartStore.cart.items.first.product.id, product.id);
        expect(cartStore.cart.items.first.quantity, 1);
      });

      test('GIVEN product already in cart '
          'WHEN addProduct is called '
          'THEN should increment quantity', () {
        cartStore.addProduct(product);
        cartStore.addProduct(product);

        expect(cartStore.cart.items.length, 1);
        expect(cartStore.cart.items.first.quantity, 2);
      });

      test('GIVEN cart is full '
          'WHEN addProduct is called with new product '
          'THEN should not add product', () {
        for (var i = 0; i < CartStore.maxDifferentProducts; i++) {
          cartStore.addProduct(TestHelpers.createTestProduct(id: i));
        }

        final newProduct = TestHelpers.createTestProduct(id: 100);
        cartStore.addProduct(newProduct);

        expect(cartStore.cart.items.length, CartStore.maxDifferentProducts);
        expect(
          cartStore.cart.items.any((item) => item.product.id == 100),
          isFalse,
        );
      });

      test('GIVEN a cart '
          'WHEN addProduct is called '
          'THEN should notify listeners', () {
        var notified = false;
        cartStore.addListener(() => notified = true);

        cartStore.addProduct(TestHelpers.createTestProduct());

        expect(notified, isTrue);
      });
    });

    group('removeProduct', () {
      test('GIVEN product with quantity > 1 '
          'WHEN removeProduct is called '
          'THEN should decrement quantity', () {
        cartStore.addProduct(product);
        cartStore.addProduct(product);
        cartStore.removeProduct(product);

        expect(cartStore.cart.items.first.quantity, 1);
      });

      test('GIVEN product with quantity 1 '
          'WHEN removeProduct is called '
          'THEN should remove product when quantity becomes 0', () {
        cartStore.addProduct(product);
        cartStore.removeProduct(product);

        expect(cartStore.cart.items, isEmpty);
      });

      test('GIVEN product is not in cart '
          'WHEN removeProduct is called '
          'THEN should do nothing', () {
        cartStore.removeProduct(product);

        expect(cartStore.cart.items, isEmpty);
      });

      test('GIVEN product in cart '
          'WHEN removeProduct is called '
          'THEN should notify listeners', () {
        cartStore.addProduct(product);

        var notified = false;
        cartStore.addListener(() => notified = true);

        cartStore.removeProduct(product);

        expect(notified, isTrue);
      });
    });

    group('removeItem', () {
      test('GIVEN item with quantity 2 '
          'WHEN removeItem is called '
          'THEN should remove entire item from cart', () {
        cartStore.addProduct(product);
        cartStore.addProduct(product);

        final item = cartStore.cart.items.first;
        cartStore.removeItem(item);

        expect(cartStore.cart.items, isEmpty);
      });

      test('GIVEN item in cart '
          'WHEN removeItem is called '
          'THEN should notify listeners', () {
        cartStore.addProduct(product);

        var notified = false;
        cartStore.addListener(() => notified = true);

        cartStore.removeItem(cartStore.cart.items.first);

        expect(notified, isTrue);
      });
    });

    group('updateQuantity', () {
      test('GIVEN item in cart '
          'WHEN updateQuantity is called with 5 '
          'THEN should update quantity of existing item', () {
        cartStore.addProduct(product);

        final item = cartStore.cart.items.first;
        cartStore.updateQuantity(item, 5);

        expect(cartStore.cart.items.first.quantity, 5);
      });

      test('GIVEN item in cart '
          'WHEN updateQuantity is called with 0 '
          'THEN should remove item', () {
        cartStore.addProduct(product);

        final item = cartStore.cart.items.first;
        cartStore.updateQuantity(item, 0);

        expect(cartStore.cart.items, isEmpty);
      });

      test('GIVEN item in cart '
          'WHEN updateQuantity is called with negative value '
          'THEN should remove item', () {
        cartStore.addProduct(product);

        final item = cartStore.cart.items.first;
        cartStore.updateQuantity(item, -1);

        expect(cartStore.cart.items, isEmpty);
      });

      test('GIVEN item in cart '
          'WHEN updateQuantity is called '
          'THEN should notify listeners', () {
        cartStore.addProduct(product);

        var notified = false;
        cartStore.addListener(() => notified = true);

        cartStore.updateQuantity(cartStore.cart.items.first, 5);

        expect(notified, isTrue);
      });

      test('GIVEN item does not exist '
          'WHEN updateQuantity is called '
          'THEN should not update', () {
        final product = TestHelpers.createTestProduct(id: 1);
        final otherProduct = TestHelpers.createTestProduct(id: 2);
        cartStore.addProduct(product);

        final fakeItem = TestHelpers.createTestCartItem(
          product: otherProduct,
          quantity: 1,
        );
        cartStore.updateQuantity(fakeItem, 5);

        expect(cartStore.cart.items.length, 1);
        expect(cartStore.cart.items.first.quantity, 1);
      });
    });

    group('clearCart', () {
      test('GIVEN cart with items '
          'WHEN clearCart is called '
          'THEN should remove all items from cart', () {
        cartStore.addProduct(TestHelpers.createTestProduct(id: 1));
        cartStore.addProduct(TestHelpers.createTestProduct(id: 2));
        cartStore.addProduct(TestHelpers.createTestProduct(id: 3));

        cartStore.clearCart();

        expect(cartStore.cart.items, isEmpty);
      });

      test('GIVEN cart with items '
          'WHEN clearCart is called '
          'THEN should notify listeners', () {
        cartStore.addProduct(TestHelpers.createTestProduct());

        var notified = false;
        cartStore.addListener(() => notified = true);

        cartStore.clearCart();

        expect(notified, isTrue);
      });
    });

    group('cart calculations', () {
      test('GIVEN cart with 3 total items '
          'WHEN totalQuantity is accessed '
          'THEN should calculate correct total quantity', () {
        cartStore.addProduct(TestHelpers.createTestProduct(id: 1));
        cartStore.addProduct(TestHelpers.createTestProduct(id: 1));
        cartStore.addProduct(TestHelpers.createTestProduct(id: 2));

        expect(cartStore.cart.totalQuantity, 3);
      });

      test('GIVEN cart with items of different prices '
          'WHEN subtotal is accessed '
          'THEN should calculate correct subtotal', () {
        cartStore.addProduct(TestHelpers.createTestProduct(id: 1, price: 10.0));
        cartStore.addProduct(TestHelpers.createTestProduct(id: 1, price: 10.0));
        cartStore.addProduct(TestHelpers.createTestProduct(id: 2, price: 20.0));

        expect(cartStore.cart.subtotal, 40.0);
      });

      test('GIVEN cart with 2 different products '
          'WHEN itemCount is accessed '
          'THEN should calculate correct item count', () {
        cartStore.addProduct(TestHelpers.createTestProduct(id: 1));
        cartStore.addProduct(TestHelpers.createTestProduct(id: 1));
        cartStore.addProduct(TestHelpers.createTestProduct(id: 2));

        expect(cartStore.cart.itemCount, 2);
      });
    });
  });
}
