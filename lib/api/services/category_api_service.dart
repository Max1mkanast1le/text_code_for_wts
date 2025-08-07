import '../base_api_service.dart';
import '../../models/category_model.dart';

class CategoryApiService extends BaseApiService {

  Future<List<Category>> fetchCategories() async {
    const endpoint = 'common/category/list?';

    final data = await getRequest(endpoint);

    if (data is Map<String, dynamic> && data.containsKey('categories')) {
      final categoriesList = data['categories'] as List;
      return categoriesList
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      // Если 'data' пуста или не содержит 'categories', возвращаем пустой список
      return [];
    }
  }
}