import 'package:json_annotation/json_annotation.dart';

// Эта строка связывает наш файл с сгенерированным файлом.
// Имя должно быть 'имя_текущего_файла.g.dart'
part 'category_model.g.dart';

// Аннотация, которая говорит генератору, что для этого класса нужно создать код
@JsonSerializable()
class Category {
  // Используем аннотацию @JsonKey, чтобы связать поле 'id' в классе
  // с полем 'categoryId' в JSON.
  @JsonKey(name: 'categoryId')
  final int id;

  // Если имя поля в классе и в JSON совпадают, @JsonKey не нужна.
  // Но я добавил для примера. Если в JSON поле 'title', а в классе 'name',
  // то @JsonKey(name: 'title') обязательна.
  @JsonKey(name: 'title')
  final String name;

  // Укажем значение по умолчанию, если поле в JSON отсутствует или null.
  @JsonKey(name: 'imageUrl', defaultValue: '')
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  // Эта фабрика будет использовать сгенерированный код.
  // _$CategoryFromJson - это имя функции, которую сгенерирует build_runner.
  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  // Этот метод тоже будет сгенерирован автоматически.
  // Полезен, если нужно будет отправлять данные на сервер.
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}