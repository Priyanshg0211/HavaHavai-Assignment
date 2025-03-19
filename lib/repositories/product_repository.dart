import 'dart:convert';
import 'package:ecommerce/models/product_model.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  final String baseUrl = 'https://dummyjson.com/products';

  Future<Map<String, dynamic>> fetchProducts(int page, int limit) async {
    final skip = (page - 1) * limit;
    final response = await http.get(
      Uri.parse('$baseUrl?limit=$limit&skip=$skip'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Product> products =
          (data['products'] as List)
              .map((productJson) => Product.fromJson(productJson))
              .toList();

      return {
        'products': products,
        'total': data['total'],
        'skip': data['skip'],
        'limit': data['limit'],
      };
    } else {
      throw Exception('Failed to load products');
    }
  }
}
