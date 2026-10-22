// lib/models/menu_item.dart

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl; // network URL; null = use placeholder
  final bool isAvailable;
  final bool isVeg;
  final double rating;
  final int prepTimeMinutes;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    this.isVeg = true,
    this.rating = 4.5,
    this.prepTimeMinutes = 15,
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    bool? isVeg,
    double? rating,
    int? prepTimeMinutes,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isVeg: isVeg ?? this.isVeg,
      rating: rating ?? this.rating,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
    );
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String? ?? 'Main',
      imageUrl: map['image_url'] as String?,
      isAvailable: map['is_available'] as bool? ?? true,
      isVeg: map['is_veg'] as bool? ?? true,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      prepTimeMinutes: map['prep_time_minutes'] as int? ?? 15,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'category': category,
    'image_url': imageUrl,
    'is_available': isAvailable,
    'is_veg': isVeg,
    'rating': rating,
    'prep_time_minutes': prepTimeMinutes,
  };
}
