import 'package:flutter/foundation.dart';
import '../models/product_detail_model.dart';
import '../repositories/product_repository.dart';

enum ViewState { idle, loading, success, error }

class ProductDetailViewModel extends ChangeNotifier {
  final IProductRepository _repository;
  final int productId;

  ProductDetailViewModel({required this.productId, IProductRepository? repository})
      : _repository = repository ?? ProductRepository() {
    fetchProductDetails();
  }

  // --- Состояние ---
  ViewState _state = ViewState.idle;
  ProductDetails? _productDetails;
  String _errorMessage = '';

  // --- Геттеры ---
  ViewState get state => _state;
  ProductDetails? get productDetails => _productDetails;
  String get errorMessage => _errorMessage;

  // --- Логика ---
  Future<void> fetchProductDetails() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _productDetails = await _repository.getProductDetails(productId);
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }
}