import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../view_models/catalog_view_model.dart';
import '../widgets/category_grid_item.dart';
import 'product_list_screen.dart';

class CatalogScreen extends StatelessWidget {
  static const routeName = '/catalog';

  const CatalogScreen({super.key});

  void _navigateToProductList(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreenWrapper(
          categoryId: category.id,
          categoryName: category.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог'),
      ),
      body: Consumer<CatalogViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.state) {
            case ViewState.loading:
              return const Center(child: CircularProgressIndicator());
            case ViewState.error:
              return Center(child: Text('Ошибка загрузки: ${viewModel.errorMessage}'));
            case ViewState.success:
              if (viewModel.categories.isEmpty) {
                return const Center(child: Text('Категории не найдены'));
              }
              // Данные успешно загружены, строим сетку
              final categories = viewModel.categories;
              return GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 3.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: categories.length,
                itemBuilder: (ctx, i) => CategoryGridItem(
                  category: categories[i],
                  onTap: () => _navigateToProductList(context, categories[i]),
                ),
              );
            default: // idle state
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}