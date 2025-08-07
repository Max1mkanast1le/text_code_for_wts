import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../view_models/product_list_view_model.dart';
import '../widgets/product_list_item.dart';
import 'product_detail_screen.dart';

// 1. Делаем виджет-обертку, которая будет создавать Provider
class ProductListScreenWrapper extends StatelessWidget {
  final int? categoryId;
  final String? categoryName;

  const ProductListScreenWrapper({super.key, this.categoryId, this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Создаем Provider здесь, НАД экраном
    return ChangeNotifierProvider(
      create: (context) => ProductListViewModel(categoryId: categoryId),
      child: ProductListScreen(categoryName: categoryName),
    );
  }
}

// 2. Сам экран теперь снова StatelessWidget и он "чистый"
class ProductListScreen extends StatefulWidget {
  final String? categoryName;

  const ProductListScreen({super.key, this.categoryName});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<ProductListViewModel>(context, listen: false);
    _scrollController.addListener(() {
      _onScroll(viewModel);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll(ProductListViewModel viewModel) {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      viewModel.loadMoreProducts();
    }
  }

  void _navigateToProductDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreenWrapper(
          productId: product.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductListViewModel>();
    final state = viewModel.state;
    final products = viewModel.products;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'Товары'),
      ),
      body: _buildBody(viewModel, state, products),
    );
  }

  Widget _buildBody(ProductListViewModel viewModel, ViewState state, List<Product> products) {
    if (state == ViewState.loading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state == ViewState.error && products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка загрузки: ${viewModel.errorMessage}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => viewModel.fetchProducts(isRefresh: true),
              child: const Text('Попробовать снова'),
            )
          ],
        ),
      );
    }

    if (products.isEmpty && state != ViewState.loading) {
      return RefreshIndicator(
        onRefresh: () => viewModel.fetchProducts(isRefresh: true),
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Center(heightFactor: 10, child: Text('Товары в этой категории не найдены')),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchProducts(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: products.length + (viewModel.hasMore ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
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