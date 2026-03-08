class Restaurant {
  final String id;
  final String name;
  final String description;
  final String pictureId;
  final String city;
  final String address;
  final double rating;
  final List<String> foods;
  final List<String> drinks;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.pictureId,
    required this.city,
    required this.address,
    required this.rating,
    required this.foods,
    required this.drinks,
  });

  factory Restaurant.fromListJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: '',
      pictureId: json['pictureId'],
      city: json['city'],
      address: '',
      rating: (json['rating'] as num).toDouble(),
      foods: [],
      drinks: [],
    );
  }

  factory Restaurant.fromDetailJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pictureId: json['pictureId'],
      city: json['city'],
      address: json['address'],
      rating: (json['rating'] as num).toDouble(),
      foods: List<String>.from(
        json['menus']['foods'].map((e) => e['name']),
      ),
      drinks: List<String>.from(
        json['menus']['drinks'].map((e) => e['name']),
      ),
    );
  }
}