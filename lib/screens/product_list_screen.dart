import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../view_models/product_list_view_model.dart';
import '../widgets/product_list_item.dart';
import 'product_detail_screen.dart';

// Виджет-обертка, который создает и предоставляет ViewModel.
class ProductListScreenWrapper extends StatelessWidget {
  final int? categoryId;
  final String? categoryName;

  const ProductListScreenWrapper({super.key, this.categoryId, this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Создаем Provider здесь, НАД экраном, чтобы экран мог его получить.
    return ChangeNotifierProvider(
      create: (context) => ProductListViewModel(categoryId: categoryId),
      // Передаем categoryName в сам экран для отображения в AppBar.
      child: ProductListScreen(categoryName: categoryName),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  final String? categoryName;

  const ProductListScreen({super.key, this.categoryName});

  // Метод для навигации на экран деталей продукта.
  void _navigateToProductDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Переходим на ProductDetailScreenWrapper, который создаст свой ViewModel.
        builder: (context) => ProductDetailScreenWrapper(
          productId: product.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Этот виджет будет автоматически перестраиваться при вызове notifyListeners() в ViewModel.
    final viewModel = context.watch<ProductListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName ?? 'Товары'),
      ),
      body: _buildBody(context, viewModel),
    );
  }

  // Отдельный метод для построения тела экрана в зависимости от состояния ViewModel.
  Widget _buildBody(BuildContext context, ProductListViewModel viewModel) {
    final state = viewModel.state;
    final products = viewModel.products;

    // 1. Состояние начальной загрузки
    if (state == ViewState.loading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Состояние ошибки при начальной загрузке
    if (state == ViewState.error && products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ошибка загрузки:\n${viewModel.errorMessage}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.fetchProducts(),
                child: const Text('Попробовать снова'),
              )
            ],
          ),
        ),
      );
    }

    // 3. Состояние, когда товары не найдены (список пуст после загрузки)
    if (products.isEmpty) {
      // Оборачиваем в RefreshIndicator, чтобы можно было обновить пустой экран.
      return RefreshIndicator(
        onRefresh: () => viewModel.fetchProducts(),
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Center(
            heightFactor: 10,
            child: Text('Товары в этой категории не найдены'),
          ),
        ),
      );
    }

    // 4. Основное состояние: показываем список товаров
    return RefreshIndicator(
      onRefresh: () => viewModel.fetchProducts(),
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (ctx, i) {
          final product = products[i];
          return ProductListItem(
            product: product,
            onTap: () => _navigateToProductDetail(context, product),
          );
        },
      ),
    );
  }
}