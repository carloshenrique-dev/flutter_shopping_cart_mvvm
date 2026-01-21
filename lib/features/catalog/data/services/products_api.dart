import 'dart:convert';

import 'package:http/http.dart' as http;

import '../dto/product_dto.dart';
import '../../domain/models/product.dart';

class ProductsApi {
  static const _baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
    return jsonList
        .map(
          (json) =>
              ProductDto.fromJson(json as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }
}
