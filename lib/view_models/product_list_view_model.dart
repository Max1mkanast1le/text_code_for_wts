import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

enum ViewState { idle, loading, success, error }

class ProductListViewModel extends ChangeNotifier {
  final IProductRepository _repository;
  final int? categoryId;

  ProductListViewModel({
    required this.categoryId,
    IProductRepository? repository,
  }) : _repository = repository ?? ProductRepository() {
    // Сразу запускаем начальную загрузку
    fetchProducts();
  }

  // --- Состояние ---
  ViewState _state = ViewState.idle;
  List<Product> _products = [];
  String _errorMessage = '';

  // --- Геттеры для доступа из View ---
  ViewState get state => _state;
  List<Product> get products => _products;
  String get errorMessage => _errorMessage;

  // --- Логика ---

  // Начальная загрузка или Pull-to-refresh
  Future<void> fetchProducts() async {
    _state = ViewState.loading;
    _products = [];
    notifyListeners();

    try {
      final newProducts = await _repository.getProducts(categoryId: categoryId);
      _products.addAll(newProducts);
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

}