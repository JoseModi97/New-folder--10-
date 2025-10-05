class ProductRating {
  final double rate;
  final int count;
  const ProductRating({required this.rate, required this.count});

  factory ProductRating.fromJson(Map<String, dynamic> json) => ProductRating(
        rate: (json['rate'] as num).toDouble(),
        count: (json['count'] as num).toInt(),
      );
}

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final ProductRating rating;
  final int inventory;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.inventory,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
        description: json['description'] as String,
        category: json['category'] as String,
        image: json['image'] as String,
        rating: ProductRating.fromJson((json['rating'] as Map).cast<String, dynamic>()),
        inventory: (json['inventory'] as num? ?? 0).toInt(),
      );

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
    ProductRating? rating,
    int? inventory,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      inventory: inventory ?? this.inventory,
    );
  }
}

