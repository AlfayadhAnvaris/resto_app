class FavoriteRestaurant {
  final String id;
  final String name;
  final String pictureId;
  final String city;
  final double rating;

  FavoriteRestaurant({
    required this.id,
    required this.name,
    required this.pictureId,
    required this.city,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'pictureId': pictureId,
      'city': city,
      'rating': rating,
    };
  }

  factory FavoriteRestaurant.fromMap(Map<String, dynamic> map) {
    return FavoriteRestaurant(
      id: map['id'],
      name: map['name'],
      pictureId: map['pictureId'],
      city: map['city'],
      rating: map['rating'],
    );
  }

  // Tambahan baru
  Map<String, dynamic> toJson() => toMap();

  factory FavoriteRestaurant.fromJson(Map<String, dynamic> json) =>
      FavoriteRestaurant.fromMap(json);
}