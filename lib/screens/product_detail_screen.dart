import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/product_detail_view_model.dart';
import '../widgets/image_carousel.dart'; // <-- Импортируем наш новый виджет

// Обертка для создания провайдера
class ProductDetailScreenWrapper extends StatelessWidget {
  final int productId;

  const ProductDetailScreenWrapper({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductDetailViewModel(productId: productId),
      child: const ProductDetailScreen(),
    );
  }
}

// Сам экран
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем ViewModel из Provider'а
    final viewModel = context.watch<ProductDetailViewModel>();

    return Scaffold(
      appBar: AppBar(
        // Заголовок обновляется в зависимости от состояния
        title: Text(viewModel.state == ViewState.success
            ? viewModel.productDetails?.name ?? 'Детали'
            : 'Загрузка...'),
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, ProductDetailViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewState.error:
        return Center(child: Text('Ошибка загрузки: ${viewModel.errorMessage}'));
      case ViewState.success:
        if (viewModel.productDetails == null) {
          return const Center(child: Text('Товар не найден'));
        }
        final product = viewModel.productDetails!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Используем наш новый чистый виджет
              ImageCarousel(images: product.images),
              const SizedBox(height: 20),
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                '${product.price.toStringAsFixed(2)} RUB',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Описание:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                product.description.isNotEmpty ? product.description : 'Описание отсутствует.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}