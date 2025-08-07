import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

enum ViewState { idle, loading, success, error, loadingMore }

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
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _limit = 8;

  // --- Геттеры для доступа из View ---
  ViewState get state => _state;
  List<Product> get products => _products;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // --- Логика ---

  // Начальная загрузка или Pull-to-refresh
  Future<void> fetchProducts({bool isRefresh = false}) async {
    // Не даем запускать, если уже идет загрузка
    if (_state == ViewState.loading || _state == ViewState.loadingMore) return;

    if (isRefresh) {
      _currentPage = 1;
      _products = [];
      _hasMore = true;
    }

    _state = ViewState.loading;
    notifyListeners();

    try {
      final newProducts = await _repository.getProducts(
        categoryId: categoryId,
        page: _currentPage,
      );

      if (newProducts.length < _limit) {
        _hasMore = false;
      }

      _products.addAll(newProducts);
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> loadMoreProducts() async {
    if (_state == ViewState.loading || _state == ViewState.loadingMore || !_hasMore) return;

    _state = ViewState.loadingMore;
    notifyListeners();

    _currentPage++;
    try {
      final newProducts = await _repository.getProducts(
        categoryId: categoryId,
        page: _currentPage,
      );

      if (newProducts.length < _limit) {
        _hasMore = false;
      }

      _products.addAll(newProducts);
      _state = ViewState.success;

    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }
}