import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart'; // Убедись, что путь к константам верный

abstract class BaseApiService {
  final http.Client _client;

  // Используем конструктор, чтобы можно было подменить http.Client для тестов
  BaseApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Выполняет GET-запрос и базовую обработку ответа.
  /// Возвращает поле 'data' в случае успеха.
  /// Выбрасывает исключение в случае ошибки.
  Future<dynamic> getRequest(String endpoint) async {
    final url = '$baseUrl/$endpoint&appKey=$apiKey';

    try {
      final response = await _client.get(Uri.parse(url));

      // 1. Декодируем тело ответа
      final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));

      if (decodedJson is! Map) {
        throw Exception('API Error: Ответ не является JSON объектом. URL: $url');
      }

      // 2. Проверяем статус-код HTTP
      if (response.statusCode != 200) {
        String errorMessage = decodedJson['error'] ?? 'Неизвестная ошибка API';
        throw Exception('Ошибка запроса (статус: ${response.statusCode}): $errorMessage');
      }

      // 3. Проверяем флаг 'success' от API
      if (decodedJson.containsKey('success') && decodedJson['success'] == false) {
        String errorMessage = decodedJson['error'] ?? decodedJson['data']?['message'] ?? 'API вернул success=false';
        throw Exception('Ошибка API: $errorMessage');
      }

      // 4. Возвращаем только полезные данные
      return decodedJson['data'];

    } catch (e) {
      // Перехватываем и выбрасываем ошибку с более понятным сообщением
      print('Ошибка при выполнении запроса к $url: $e');
      rethrow; // rethrow сохраняет оригинальный stack trace
    }
  }
}