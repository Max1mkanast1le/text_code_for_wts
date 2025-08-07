import 'package:flutter/foundation.dart' hide Category;
import 'package:wts_app/models/category_model.dart';
import '../repositories/category_repository.dart';

enum ViewState { idle, loading, success, error }

class CatalogViewModel extends ChangeNotifier {
  final ICategoryRepository _categoryRepository;

  CatalogViewModel({ICategoryRepository? categoryRepository})
      : _categoryRepository = categoryRepository ?? CategoryRepository() {
    // Загружаем категории сразу при создании ViewModel
    fetchCategories();
  }

  // Приватные переменные для хранения состояния
  ViewState _state = ViewState.idle;
  List<Category> _categories = [];
  String _errorMessage = '';

  // Публичные геттеры, чтобы View мог получить данные, но не мог их изменить
  ViewState get state => _state;
  List<Category> get categories => _categories;
  String get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      // 2. Получаем данные из репозитория
      _categories = await _categoryRepository.getCategories();

      // 3. Устанавливаем состояние "успех"
      _state = ViewState.success;
    } catch (e) {
      // 4. В случае ошибки, сохраняем сообщение и ставим состояние "ошибка"
      _errorMessage = e.toString();
      _state = ViewState.error;
    }

    // 5. Уведомляем слушателей (View) о финальном состоянии
    notifyListeners();
  }
}