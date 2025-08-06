import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/catalog_view_model.dart'; // <-- Импортируй ViewModel
import 'screens/catalog_screen.dart'; // <-- Импортируй экран

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Оборачиваем MaterialApp в MultiProvider
    return MultiProvider(
      providers: [
        // Здесь мы "предоставляем" CatalogViewModel всему приложению
        ChangeNotifierProvider(
          create: (context) => CatalogViewModel(),
        ),
        // Сюда можно добавлять другие ViewModel для других экранов
        // ChangeNotifierProvider(create: (context) => ProductListViewModel()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Установим CatalogScreen как домашний экран для примера
        home: const CatalogScreen(),
        routes: {
          // если у тебя есть роуты, оставь их
          CatalogScreen.routeName: (ctx) => const CatalogScreen(),
        },
      ),
    );
  }
}