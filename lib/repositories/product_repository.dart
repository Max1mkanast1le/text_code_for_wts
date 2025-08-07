import '../api/services/product_api_service.dart';
import '../models/product_detail_model.dart';
import '../models/product_model.dart';

// Абстрактный класс (интерфейс) для репозитория.
abstract class IProductRepository {
  Future<List<Product>> getProducts({int? categoryId, int page = 1});
  Future<ProductDetails> getProductDetails(int productId);
}

class ProductRepository implements IProductRepository {
  // Репозиторий зависит от API-сервиса
  final ProductApiService _apiService;

  ProductRepository({ProductApiService? apiService})
      : _apiService = apiService ?? ProductApiService();

  @override
  Future<List<Product>> getProducts({int? categoryId, int page = 1}) async {
    // В будущем здесь можно добавить логику кэширования:
    // 1. Проверить, есть ли данные в кэше.
    // 2. Если есть - вернуть из кэша.
    // 3. Если нет - запросить из API, сохранить в кэш и вернуть.
    try {
      // Пока просто проксируем вызов к API-сервису
      final products = await _apiService.fetchProducts(categoryId: categoryId, page: page);
      return products;
    } catch (e) {
      // Здесь можно обрабатывать ошибки специфичные для репозитория
      print('Ошибка в ProductRepository.getProducts: $e');
      // Пробрасываем ошибку дальше, чтобы ее обработал ViewModel
      rethrow;
    }
  }

  @override
  Future<ProductDetails> getProductDetails(int productId) async {
    try {
      final details = await _apiService.fetchProductDetails(productId);
      return details;
    } catch (e) {
      print('Ошибка в ProductRepository.getProductDetails: $e');
      rethrow;
    }
  }
}