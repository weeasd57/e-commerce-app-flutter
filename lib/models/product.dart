class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? categoryId;
  final List<String> imageUrls;
  final bool isHot;
  final bool isNew;
  final bool onSale;
  final double? salePrice;
  final DateTime createdAt;
  final String? age;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.categoryId,
    required this.imageUrls,
    this.isHot = false,
    this.isNew = false,
    this.onSale = false,
    this.salePrice,
    required this.createdAt,
    this.age,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    try {
      return Product(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? 'Unknown Product',
        description: map['description']?.toString() ?? '',
        price: map['price'] != null ? (map['price'] as num).toDouble() : 0.0,
        categoryId: map['category_id']?.toString(),
        imageUrls: map['image_urls'] != null 
            ? List<String>.from(map['image_urls'] as List)
            : [],
        isHot: map['is_hot'] as bool? ?? false,
        isNew: map['is_new'] as bool? ?? false,
        onSale: map['on_sale'] as bool? ?? false,
        salePrice: map['sale_price'] != null
            ? (map['sale_price'] as num).toDouble()
            : null,
        createdAt: map['createdAt'] != null 
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
        age: map['age']?.toString(),
      );
    } catch (e) {
      // Return a default product if parsing fails
      return Product(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? 'Unknown Product',
        description: map['description']?.toString() ?? '',
        price: 0.0,
        categoryId: null,
        imageUrls: [],
        isHot: false,
        isNew: false,
        onSale: false,
        salePrice: null,
        createdAt: DateTime.now(),
        age: null,
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrls': imageUrls,
      'isHot': isHot,
      'isNew': isNew,
      'onSale': onSale,
      'salePrice': salePrice,
      'createdAt': createdAt.toIso8601String(),
      'age': age,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    List<String>? imageUrls,
    bool? isHot,
    bool? isNew,
    bool? onSale,
    double? salePrice,
    DateTime? createdAt,
    String? age,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrls: imageUrls ?? this.imageUrls,
      isHot: isHot ?? this.isHot,
      isNew: isNew ?? this.isNew,
      onSale: onSale ?? this.onSale,
      salePrice: salePrice ?? this.salePrice,
      createdAt: createdAt ?? this.createdAt,
      age: age ?? this.age,
    );
  }
}
