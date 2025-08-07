import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_models/catalog_view_model.dart';
import 'screens/catalog_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CatalogViewModel(),
        ),
        // Сюда можно добавлять другие ViewModel для других экранов
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const CatalogScreen(),
        routes: {
          CatalogScreen.routeName: (ctx) => const CatalogScreen(),
        },
      ),
    );
  }
}