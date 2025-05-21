class ProductDetails {
  final int id;
  final String name;
  final String description;
  final double price;
  final List<String> images;


  ProductDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      if (json['price'] is String) {
        parsedPrice = double.tryParse(json['price'].toString().replaceAll(',', '.')) ?? 0.0;
      } else if (json['price'] is num) {
        parsedPrice = (json['price'] as num).toDouble();
      }
    }

    List<String> imageList = [];
    if (json['images'] != null && json['images'] is List) {
      imageList = List<String>.from(
          (json['images'] as List).map((image) => image?.toString() ?? '').where((imgStr) => imgStr.isNotEmpty)
      );
    }
    // Если список 'images' пуст, но есть 'imageUrl', добавим его
    if (imageList.isEmpty && json['imageUrl'] != null && json['imageUrl'] is String && (json['imageUrl'] as String).isNotEmpty) {
      imageList.add(json['imageUrl'] as String);
    }

    int productId = -1;
    productId = (json['productId'] as num).toInt();

    return ProductDetails(
      id: productId,
      name: json['title'] as String? ?? 'Название отсутствует',
      description: json['productDescription'] as String? ?? 'Описание отсутствует',
      price: parsedPrice,
      images: imageList,
    );
  }
}