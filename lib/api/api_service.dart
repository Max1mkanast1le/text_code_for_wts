import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../models/product_detail_model.dart';

class ApiService {
  Future<List<T>> _fetchList<T>(String url, T Function(Map<String, dynamic>) fromJson) async {
    final response = await http.get(Uri.parse(url));
    final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
    final List<dynamic> dataListJson = decodedJson['data'] as List<dynamic>;
    return dataListJson.map((jsonItem) => fromJson(jsonItem as Map<String, dynamic>)).toList();
  }


  Future<List<Category>> fetchCategories() async {
    String url = '$baseUrl/common/category/list?appKey=$apiKey';
    final response = await http.get(Uri.parse(url));
    final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
    final List<dynamic> categoriesJsonList = decodedJson['data']['categories'];
    return categoriesJsonList.map((jsonItem) => Category.fromJson(jsonItem as Map<String, dynamic>)).toList();
  }

  Future<List<Product>> fetchProducts({int? categoryId}) async {
    String url = '$baseUrl/common/product/list?appKey=$apiKey&categoryId=$categoryId';
    return _fetchList<Product>(url, (json) => Product.fromJson(json));
  }

  Future<ProductDetails> fetchProductDetails(int productId) async {
    String url = '$baseUrl/common/product/details?appKey=$apiKey&productId=$productId';
    final response = await http.get(Uri.parse(url));
    final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
    final Map<String, dynamic> productDataJson = decodedJson['data'] as Map<String, dynamic>;
    return ProductDetails.fromJson(productDataJson);
  }
}