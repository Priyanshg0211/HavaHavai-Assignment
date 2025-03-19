import 'dart:convert';
import 'package:ecommerce/models/product_model.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  final String baseUrl = 'https://dummyjson.com/products';

  // Get products with pagination
  Future<List<Product>> getProducts({
    required int page,
    required int limit,
  }) async {
    final skip = (page - 1) * limit;
    final response = await http.get(
      Uri.parse('$baseUrl?limit=$limit&skip=$skip'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Product>.from(
        (data['products'] as List).map(
          (productJson) => Product.fromJson(productJson),
        ),
      );
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Get total product count
  Future<int> getTotalProductCount({
    String? category,
    String? searchQuery,
  }) async {
    Uri uri;

    if (category != null && category.isNotEmpty) {
      uri = Uri.parse('$baseUrl/category/$category?limit=1');
    } else if (searchQuery != null && searchQuery.isNotEmpty) {
      uri = Uri.parse('$baseUrl/search?q=$searchQuery&limit=1');
    } else {
      uri = Uri.parse('$baseUrl?limit=1');
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['total'] as int;
    } else {
      throw Exception('Failed to get total product count');
    }
  }

  // Search products
  Future<List<Product>> searchProducts({
    required String query,
    required int page,
    required int limit,
  }) async {
    final skip = (page - 1) * limit;
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=$query&limit=$limit&skip=$skip'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Product>.from(
        (data['products'] as List).map(
          (productJson) => Product.fromJson(productJson),
        ),
      );
    } else {
      throw Exception('Failed to search products');
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory({
    required String category,
    required int page,
    required int limit,
  }) async {
    final skip = (page - 1) * limit;
    final response = await http.get(
      Uri.parse('$baseUrl/category/$category?limit=$limit&skip=$skip'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Product>.from(
        (data['products'] as List).map(
          (productJson) => Product.fromJson(productJson),
        ),
      );
    } else {
      throw Exception('Failed to load products by category');
    }
  }
}
