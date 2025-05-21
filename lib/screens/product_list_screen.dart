import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../api/api_service.dart';
import '../widgets/product_list_item.dart';
import 'product_detail_screen.dart';
// '../api/api_service_production.dart';

class ProductListScreen extends StatefulWidget {
  static const routeName = '/product-list';
  final int? categoryId;
  final String? categoryName;

  const ProductListScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService _apiService = ApiService();
  final List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 8; // Количество товаров на страницу
  String? _error;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts({bool isRefresh = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _products.clear();
        _currentPage = 1;
        _hasMore = true;
      }
      _error = null;
    });

    try {
      final newProducts = await _apiService.fetchProducts(
        categoryId: widget.categoryId
      );
      setState(() {
        _products.addAll(newProducts);
        _isLoading = false;
        if (newProducts.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
        _hasMore = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;
    try {
      // Запрашиваем следующую порцию товаров
      final List<Product> fetchedPage = await _apiService.fetchProducts(
        categoryId: widget.categoryId
      );

      final Set<int> existingProductIds = _products.map((p) => p.id).toSet();
      final List<Product> trulyNewProducts = fetchedPage.where((p) => !existingProductIds.contains(p.id)).toList();

      setState(() {
        _products.addAll(trulyNewProducts);

        if (fetchedPage.isEmpty) {
          _hasMore = false;
        } else if (trulyNewProducts.isEmpty && fetchedPage.isNotEmpty) {
          _hasMore = false;
        } else if (fetchedPage.length < _limit) {
          _hasMore = false;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        print("Ошибка при загрузке дополнительных товаров: $e");
        _hasMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
        _hasMore &&
        !_isLoadingMore &&
        !_isLoading) {
      _loadMoreProducts();
    }
  }

  void _navigateToProductDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          key: ValueKey(product.id),
          productId: product.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'Товары'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else if (_error != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка загрузки: $_error'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _fetchProducts(isRefresh: true),
              child: const Text('Попробовать снова'),
            )
          ],
        ),
      );
    } else if (_products.isEmpty && !_hasMore) {
      return const Center(child: Text('Товары не найдены'));
    }

    return RefreshIndicator(
      onRefresh: () => _fetchProducts(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _products.length + (_hasMore ? 1 : 0), // +1 для индикатора загрузки
        itemBuilder: (ctx, i) {
          if (i == _products.length) {
            return _isLoadingMore
                ? const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ))
                : const SizedBox.shrink();
          }
          final product = _products[i];
          return ProductListItem(
            product: product,
            onTap: () => _navigateToProductDetail(context, product),
          );
        },
      ),
    );
  }
}