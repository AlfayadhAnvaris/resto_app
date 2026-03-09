// providers/favorite_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_restaurant.dart';
import '../models/restaurant.dart';

class FavoriteProvider extends ChangeNotifier {
  static const String _favoritesKey = 'favorite_restaurants';

  final List<FavoriteRestaurant> _favoriteRestaurants = [];

  List<FavoriteRestaurant> get favoriteRestaurants =>
      List.unmodifiable(_favoriteRestaurants);

  FavoriteProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_favoritesKey);

      if (favoritesJson != null) {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        _favoriteRestaurants.clear();
        _favoriteRestaurants
            .addAll(decoded.map((e) => FavoriteRestaurant.fromJson(e)).toList());
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded =
          jsonEncode(_favoriteRestaurants.map((e) => e.toJson()).toList());
      await prefs.setString(_favoritesKey, encoded);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  bool isFavorite(String id) {
    return _favoriteRestaurants.any((restaurant) => restaurant.id == id);
  }

  Future<void> addFavorite(FavoriteRestaurant restaurant) async {
    if (!isFavorite(restaurant.id)) {
      _favoriteRestaurants.add(restaurant);
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String id) async {
    _favoriteRestaurants.removeWhere((restaurant) => restaurant.id == id);
    await _saveFavorites();
    notifyListeners();
  }

  void toggleFavorite(FavoriteRestaurant restaurant) {
    if (isFavorite(restaurant.id)) {
      removeFavorite(restaurant.id);
    } else {
      addFavorite(restaurant);
    }
  }

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

  List<FavoriteRestaurant> getFavorites() => _favoriteRestaurants;

  Future<void> clearAllFavorites() async {
    _favoriteRestaurants.clear();
    await _saveFavorites();
    notifyListeners();
  }
}