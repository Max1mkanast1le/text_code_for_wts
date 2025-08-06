class Category {
  final int id;
  final String name;
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  // Возвращаем ручной парсинг JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['categoryId'] as int,
      name: json['title'] as String,
      icon: json['imageUrl'] as String? ?? '',
    );
  }
}