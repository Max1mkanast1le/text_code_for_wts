import '../base_api_service.dart';
import '../../models/product_model.dart';
import '../../models/product_detail_model.dart';

class ProductApiService extends BaseApiService {

  Future<List<Product>> fetchProducts({int? categoryId, int page = 1, int limit = 10}) async {
    String endpoint = 'common/product/list?page=$page&limit=$limit';
    if (categoryId != null) {
      endpoint += '&categoryId=$categoryId';
    }

    final data = await getRequest(endpoint);

    if (data is List) {
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      // Если API по какой-то причине не вернул список, возвращаем пустой
      return [];
    }
  }

  Future<ProductDetails> fetchProductDetails(int productId) async {
    final endpoint = 'common/product/details?id=$productId';

    final data = await getRequest(endpoint);

    if (data is Map<String, dynamic>) {
      return ProductDetails.fromJson(data);
    } else {
      throw Exception('Не удалось разобрать детали продукта: поле "data" не является объектом.');
    }
  }
}