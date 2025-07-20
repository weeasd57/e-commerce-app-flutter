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
  final double? discount; // نسبة الخصم كرقم مئوي (مثل 17 للدلالة على 17%)
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
    this.discount,
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
        discount: map['discount'] != null
            ? (map['discount'] as num).toDouble()
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
        discount: null,
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
      'discount': discount,
      'createdAt': createdAt.toIso8601String(),
      'age': age,
    };
  }

  /// السعر النهائي بعد التخفيض (إذا كان المنتج في تخفيضات)
  /// إذا لم يكن في تخفيضات، يرجع السعر الأصلي
  double get finalPrice {
    if (onSale) {
      // إذا كان هناك حقل discount محدد، استخدمه أولاً
      if (discount != null && discount! > 0) {
        // حساب السعر بناءً على نسبة الخصم
        double discountAmount = price * (discount! / 100);
        return price - discountAmount;
      }
      // إذا لم يكن هناك discount، استخدم salePrice كما هو موجود
      else if (salePrice != null && salePrice! > 0) {
        // منطق ذكي محدّث:
        // إذا كان salePrice أقل من نصف السعر الأصلي فهو غالباً مقدار خصم
        // وإذا كان أكبر فهو السعر النهائي
        if (salePrice! < (price * 0.5)) {
          // إذا كان salePrice أقل من 50% من السعر الأصلي، فهو مقدار خصم
          return price - salePrice!;
        } else {
          // إذا كان 50% أو أكثر، فهو غالباً السعر النهائي
          return salePrice!;
        }
      }
    }
    return price;
  }
  
  /// مقدار التوفير (الفرق بين السعر الأصلي والسعر النهائي)
  double get discountAmount {
    return price - finalPrice;
  }
  
  /// نسبة التخفيض كنسبة مئوية
  double get discountPercentage {
    if (price == 0) return 0;
    return (discountAmount / price) * 100;
  }
  
  /// هل يوجد تخفيض فعلي (السعر النهائي أقل من السعر الأصلي)
  bool get hasDiscount {
    return onSale && finalPrice < price;
  }
  
  /// إرجاع نسبة الخصم الصحيحة - إما من حقل discount أو محسوبة من الفرق في الأسعار
  double get actualDiscountPercentage {
    if (onSale && discount != null && discount! > 0) {
      // إذا كان هناك حقل discount محدد، استخدمه
      return discount!;
    }
    // وإلا احسب النسبة من الفرق في الأسعار
    return discountPercentage;
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
    double? discount,
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
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      age: age ?? this.age,
    );
  }
}
