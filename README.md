# Flutter Shopping Cart - MVVM

A shopping cart application built with Flutter following the MVVM architecture pattern.

## Demo

![shopping-cart](https://github.com/user-attachments/assets/01b70898-27a5-460a-930f-644264ff02f1)


## Requirements

- Flutter SDK: ^3.10.1
- Dart SDK: ^3.10.1

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Architecture

This project follows the **MVVM (Model-View-ViewModel)** pattern with **feature-first** organization.

```
lib/
├── features/
│   ├── core/
│   │   ├── domain/models/
│   │   │   └── checkout_state.dart
│   │   └── presentation/
│   │       └── viewmodels/
│   │           └── cart_store.dart       # Global Cart State
│   ├── catalog/
│   │   ├── data/
│   │   │   ├── dto/
│   │   │   │   └── product_dto.dart
│   │   │   └── services/
│   │   │       └── products_api.dart
│   │   ├── domain/models/
│   │   │   └── product.dart
│   │   └── presentation/
│   │       ├── viewmodels/
│   │       │   └── products_viewmodel.dart
│   │       ├── views/
│   │       │   └── catalog_view.dart
│   │       ├── widgets/
│   │       │   └── product_card.dart
│   │       └── strings/
│   │           └── catalog_strings.dart
│   ├── cart/
│   │   ├── data/services/
│   │   │   └── cart_api.dart
│   │   ├── domain/models/
│   │   │   ├── cart.dart
│   │   │   └── cart_item.dart
│   │   └── presentation/
│   │       ├── viewmodels/
│   │       │   └── cart_viewmodel.dart
│   │       ├── views/
│   │       │   └── cart_view.dart
│   │       ├── widgets/
│   │       │   ├── cart_item_card.dart
│   │       │   └── order_summary.dart
│   │       └── strings/
│   │           └── cart_strings.dart
│   └── checkout/
│       ├── data/services/
│       │   └── checkout_api.dart
│       ├── domain/models/
│       │   └── checkout_result.dart
│       └── presentation/
│           ├── viewmodels/
│           │   └── checkout_viewmodel.dart
│           ├── views/
│           │   └── order_complete_view.dart
│           ├── widgets/
│           │   └── order_summary_footer.dart
│           └── strings/
│               └── checkout_strings.dart
└── main.dart
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|----------------|
| **Domain/Models** | Pure business entities (Product, Cart, CartItem) |
| **Data/Services** | API calls, DTOs, data transformations |
| **ViewModels** | UI state, loading/error handling, orchestration |
| **Views** | UI screens |
| **Widgets** | Reusable UI components |
| **Strings** | UI text constants |

## Features

- **Catalog Screen**: Browse products from FakeStore API
- **Cart Management**: Add/remove items with quantity controls
- **Business Rule**: Maximum 10 different products in cart
- **Checkout Flow**: Simulated checkout with order confirmation
- **Error Handling**: User-friendly error messages

## Tech Stack

- **Flutter** 3.x
- **Provider** for state management (ChangeNotifier)
- **HTTP** for API calls
- **Native Named Routes** for navigation

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/core/presentation/viewmodels/cart_store_test.dart

# Run with coverage
flutter test --coverage
```

### Test Structure

```
test/
├── helpers/
│   └── test_helpers.dart           # Mocks, factories, widget builders
└── features/
    ├── core/presentation/viewmodels/
    │   └── cart_store_test.dart
    ├── catalog/presentation/
    │   ├── viewmodels/
    │   │   └── products_viewmodel_test.dart
    │   ├── views/
    │   │   └── catalog_view_test.dart
    │   └── widgets/
    │       └── product_card_test.dart
    ├── cart/presentation/
    │   ├── viewmodels/
    │   │   └── cart_viewmodel_test.dart
    │   ├── views/
    │   │   └── cart_view_test.dart
    │   └── widgets/
    │       ├── cart_item_card_test.dart
    │       └── order_summary_test.dart
    └── checkout/presentation/
        ├── viewmodels/
        │   └── checkout_viewmodel_test.dart
        ├── views/
        │   └── order_complete_view_test.dart
        └── widgets/
            └── order_summary_footer_test.dart
```

## API

- Products: https://fakestoreapi.com/products
- Cart & Checkout: Simulated with delays
