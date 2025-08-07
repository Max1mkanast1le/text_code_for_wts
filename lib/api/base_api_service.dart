import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart';

abstract class BaseApiService {
  final http.Client _client;

  // Используем конструктор, чтобы можно было подменить http.Client для тестов
  BaseApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> getRequest(String endpoint) async {
    final url = '$baseUrl/$endpoint&appKey=$apiKey';

    try {
      final response = await _client.get(Uri.parse(url));

      final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
      print('ОТВЕТ ОТ API ($url): $decodedJson');
      return decodedJson['data'];

    } catch (e) {
      print('Ошибка при выполнении запроса к $url: $e');
      rethrow;
    }
  }
}