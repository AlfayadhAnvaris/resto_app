// providers/favorite_provider.dart

import 'package:flutter/material.dart';
import '../models/favorite_restaurant.dart';
import '../models/restaurant.dart'; // Add this if you want to handle Restaurant type

class FavoriteProvider extends ChangeNotifier {
  final List<FavoriteRestaurant> _favoriteRestaurants = [];

  List<FavoriteRestaurant> get favoriteRestaurants => 
      List.unmodifiable(_favoriteRestaurants);

  // Check if a restaurant is favorite by ID
  bool isFavorite(String id) {
    return _favoriteRestaurants.any((restaurant) => restaurant.id == id);
  }

  // Add favorite (accepts FavoriteRestaurant)
  Future<void> addFavorite(FavoriteRestaurant restaurant) async {
    if (!isFavorite(restaurant.id)) {
      _favoriteRestaurants.add(restaurant);
      notifyListeners();
    }
  }

  // Remove favorite by ID
  Future<void> removeFavorite(String id) async {
    _favoriteRestaurants.removeWhere((restaurant) => restaurant.id == id);
    notifyListeners();
  }

  // Toggle favorite (accepts FavoriteRestaurant)
  void toggleFavorite(FavoriteRestaurant restaurant) {
    if (isFavorite(restaurant.id)) {
      removeFavorite(restaurant.id);
    } else {
      addFavorite(restaurant);
    }
  }

  // Optional: Helper method to convert and toggle Restaurant
  void toggleRestaurant(dynamic restaurant) {
    if (restaurant is Restaurant) {
      final favoriteRestaurant = FavoriteRestaurant(
        id: restaurant.id,
        name: restaurant.name,
        pictureId: restaurant.pictureId,
        city: restaurant.city,
        rating: restaurant.rating,
      );
      toggleFavorite(favoriteRestaurant);
    } else if (restaurant is FavoriteRestaurant) {
      toggleFavorite(restaurant);
    }
  }

  // Get all favorites
  List<FavoriteRestaurant> getFavorites() {
    return _favoriteRestaurants;
  }

  // Clear all favorites
  void clearAllFavorites() {
    _favoriteRestaurants.clear();
    notifyListeners();
  }
}