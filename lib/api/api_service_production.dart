import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/product_detail_model.dart';

class ApiService {
  Future<List<T>> _fetchList<T>(
      String url, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedJson is! Map) {
          throw Exception(
              'API Error: Корневой ответ не является JSON объектом. Тело ответа: ${response.body}');
        }

        if (decodedJson.containsKey('success') &&
            decodedJson['success'] == false) {
          String errorMessage = 'API вернул success=false.';
          if (decodedJson.containsKey('error') &&
              decodedJson['error'] != null) {
            errorMessage += ' Ошибка: ${decodedJson['error']}';
          } else if (decodedJson.containsKey('data') &&
              decodedJson['data'] is Map &&
              decodedJson['data'].containsKey('message')) {
            errorMessage += ' Сообщение: ${decodedJson['data']['message']}';
          }
          throw Exception(errorMessage);
        }

        final dynamic dataPayload = decodedJson['data'];

        if (dataPayload is List) {
          return dataPayload.map((item) {
            if (item is Map<String, dynamic>) {
              return fromJson(item);
            } else {
              print(
                  'API Warning: Элемент в списке "data" не является объектом (Map). Элемент: $item');
              throw Exception(
                  'Неверный формат элемента в списке данных от API.');
            }
          }).toList();
        } else if (dataPayload == null &&
            (decodedJson.containsKey('success')
                ? decodedJson['success'] == true
                : true)) {
          return [];
        } else {
          print(
              'API Error: Ожидался List для поля "data", но получен ${dataPayload.runtimeType}. ' +
                  'Payload: $dataPayload. Полный ответ: $decodedJson');
          throw Exception(
              'Не удалось разобрать список из API: поле "data" не является списком. Получено: ${dataPayload.runtimeType}');
        }
      } else {
        throw Exception(
            'Не удалось загрузить данные (статус код: ${response.statusCode}, тело: ${response.body})');
      }
    } catch (e) {
      print('Общая ошибка при выполнении запроса к $url: $e');
      throw Exception('Ошибка при получении данных: $e');
    }
  }

  Future<List<Category>> fetchCategories() async {
    final url = '$baseUrl/common/category/list?appKey=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedJson is! Map) {
          throw Exception(
              'API Error (Categories): Корневой ответ не является JSON объектом. Тело ответа: ${response.body}');
        }

        if (decodedJson.containsKey('success') &&
            decodedJson['success'] == false) {
          String errorMessage = 'API (Categories) вернул success=false.';
          if (decodedJson.containsKey('error') &&
              decodedJson['error'] != null) {
            errorMessage += ' Ошибка: ${decodedJson['error']}';
          } else if (decodedJson.containsKey('data') &&
              decodedJson['data'] is Map &&
              decodedJson['data'].containsKey('message')) {
            errorMessage += ' Сообщение: ${decodedJson['data']['message']}';
          }
          throw Exception(errorMessage);
        }

        final dynamic dataPayload = decodedJson['data'];

        if (dataPayload is Map<String, dynamic>) {
          final dynamic categoriesListPayload = dataPayload['categories'];
          if (categoriesListPayload is List) {
            return categoriesListPayload.map((item) {
              if (item is Map<String, dynamic>) {
                return Category.fromJson(item);
              } else {
                print(
                    'API Warning (Categories): Элемент в списке "categories" не является объектом (Map). Элемент: $item');
                throw Exception(
                    'Неверный формат элемента в списке категорий от API.');
              }
            }).toList();
          } else if (categoriesListPayload == null && (decodedJson.containsKey('success') ? decodedJson['success'] == true : true)) {
            return [];
          }
          else {
            print(
                'API Error (Categories): Ожидался List для поля "categories" внутри "data", но получен ${categoriesListPayload.runtimeType}. ' +
                    'Payload: $categoriesListPayload. Содержимое data: $dataPayload');
            throw Exception(
                'Не удалось разобрать список категорий: поле "categories" (внутри "data") не является списком или отсутствует.');
          }
        } else if (dataPayload == null && (decodedJson.containsKey('success') ? decodedJson['success'] == true : true)) {
          return [];
        }
        else {
          print(
              'API Error (Categories): Ожидался Map для поля "data", но получен ${dataPayload.runtimeType}. ' +
                  'Payload: $dataPayload. Полный ответ: $decodedJson');
          throw Exception(
              'Не удалось разобрать список категорий: поле "data" не является объектом. Получено: ${dataPayload.runtimeType}');
        }
      } else {
        throw Exception(
            'Не удалось загрузить категории (статус код: ${response.statusCode}, тело: ${response.body})');
      }
    } catch (e) {
      print('Общая ошибка при выполнении запроса категорий к $url: $e');
      rethrow;
    }
  }

  Future<List<Product>> fetchProducts(
      {int? categoryId, int page = 1, int limit = 10}) async {
    String url =
        '$baseUrl/common/product/list?appKey=$apiKey&page=$page&limit=$limit';
    if (categoryId != null) {
      url += '&categoryId=$categoryId';
    }
    return _fetchList<Product>(url, (json) => Product.fromJson(json));
  }

  Future<ProductDetails> fetchProductDetails(int productId) async {
    final url = '$baseUrl/common/product/details?appKey=$apiKey&id=$productId';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedJson is! Map) {
          throw Exception(
              'API Error: Корневой ответ не является JSON объектом. Тело ответа: ${response.body}');
        }

        if (decodedJson.containsKey('success') &&
            decodedJson['success'] == false) {
          String errorMessage = 'API вернул success=false.';
          if (decodedJson.containsKey('error') &&
              decodedJson['error'] != null) {
            errorMessage += ' Ошибка: ${decodedJson['error']}';
          } else if (decodedJson.containsKey('data') &&
              decodedJson['data'] is Map &&
              decodedJson['data'].containsKey('message')) {
            errorMessage += ' Сообщение: ${decodedJson['data']['message']}';
          }
          throw Exception(errorMessage);
        }

        final dynamic dataPayload = decodedJson['data'];
        if (dataPayload is Map<String, dynamic>) {
          return ProductDetails.fromJson(dataPayload);
        } else {
          print(
              'API Error: Ожидался Map для поля "data" в деталях продукта, но получен ${dataPayload.runtimeType}. ' +
                  'Payload: $dataPayload. Полный ответ: $decodedJson');
          throw Exception(
              'Не удалось разобрать детали продукта: поле "data" не является объектом. Получено: ${dataPayload.runtimeType}');
        }
      } else {
        throw Exception(
            'Не удалось загрузить детали продукта (статус код: ${response.statusCode}, тело: ${response.body})');
      }
    } catch (e) {
      print('Общая ошибка при выполнении запроса к $url: $e');
      throw Exception('Ошибка при получении деталей продукта: $e');
    }
  }
}