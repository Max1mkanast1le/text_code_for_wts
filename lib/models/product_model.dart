class Product {
  final int id;
  final String name;
  final String mainImage;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.mainImage,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    parsedPrice = (json['price'] as num).toDouble();

    int productId = -1;
    productId = (json['productId'] as num).toInt();

    return Product(
      id: productId,
      name: json['title'] as String? ?? 'Название отсутствует',
      mainImage: json['imageUrl'] as String? ?? '',
      price: parsedPrice,
    );
  }
}