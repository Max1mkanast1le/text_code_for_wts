import '../base_api_service.dart';
import '../../models/category_model.dart'; // Убедись, что путь к модели верный

class CategoryApiService extends BaseApiService {

  Future<List<Category>> fetchCategories() async {
    const endpoint = 'common/category/list?'; // Знак ? в конце, т.к. appKey добавится в базовом классе

    final data = await getRequest(endpoint);

    // Особенность эндпоинта категорий: они лежат в data -> categories
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