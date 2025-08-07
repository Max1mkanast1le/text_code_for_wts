import '../base_api_service.dart';
import '../../models/product_model.dart';
import '../../models/product_detail_model.dart';

class ProductApiService extends BaseApiService {

  Future<List<Product>> fetchProducts({int? categoryId, int limit = 20}) async {
    String endpoint = 'common/product/list?limit=$limit';
    if (categoryId != null) {
      endpoint += '&categoryId=$categoryId';
    }

    final data = await getRequest(endpoint);

    if (data is List) {
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  Future<ProductDetails> fetchProductDetails(int productId) async {
    final endpoint = 'common/product/details?productId=$productId';

    final data = await getRequest(endpoint);

    if (data is Map<String, dynamic>) {
      return ProductDetails.fromJson(data);
    }

    // Если API вернул что-то другое (null, не объект)
    throw Exception('Продукт с ID $productId не найден или неверный формат ответа.');
  }
}