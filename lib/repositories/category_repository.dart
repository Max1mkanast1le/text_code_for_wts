import '../api/services/category_api_service.dart';
import '../models/category_model.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getCategories();
}

class CategoryRepository implements ICategoryRepository {
  final CategoryApiService _apiService;

  CategoryRepository({CategoryApiService? apiService})
      : _apiService = apiService ?? CategoryApiService();

  @override
  Future<List<Category>> getCategories() async {
    try {
      return await _apiService.fetchCategories();
    } catch (e) {
      print('Ошибка в CategoryRepository.getCategories: $e');
      rethrow;
    }
  }
}