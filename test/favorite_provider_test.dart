// test/favorite_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:resto_app/models/favorite_restaurant.dart';
import 'package:resto_app/providers/favorite_provider.dart';

void main() {
  late FavoriteProvider favoriteProvider;

  setUp(() {
    favoriteProvider = FavoriteProvider();
  });

  group('FavoriteProvider Tests', () {
    test('Initial favorites list should be empty', () {
      expect(favoriteProvider.favoriteRestaurants, isEmpty);
    });

    test('isFavorite should return false for non-existent restaurant', () {
      expect(favoriteProvider.isFavorite('non-existent-id'), false);
    });

    test('addFavorite should add restaurant to favorites', () async {
      // Create test restaurant
      final restaurant = FavoriteRestaurant(
        id: 'test-id',
        name: 'Test Restaurant',
        pictureId: 'test-picture',
        city: 'Test City',
        rating: 4.5,
      );

      await favoriteProvider.addFavorite(restaurant);
      
      expect(favoriteProvider.favoriteRestaurants.length, 1);
      expect(favoriteProvider.isFavorite('test-id'), true);
    });

    test('addFavorite should not add duplicate restaurant', () async {
      final restaurant = FavoriteRestaurant(
        id: 'test-id',
        name: 'Test Restaurant',
        pictureId: 'test-picture',
        city: 'Test City',
        rating: 4.5,
      );

      await favoriteProvider.addFavorite(restaurant);
      await favoriteProvider.addFavorite(restaurant);
      
      expect(favoriteProvider.favoriteRestaurants.length, 1);
    });

    test('removeFavorite should remove restaurant from favorites', () async {
      final restaurant = FavoriteRestaurant(
        id: 'test-id',
        name: 'Test Restaurant',
        pictureId: 'test-picture',
        city: 'Test City',
        rating: 4.5,
      );

      await favoriteProvider.addFavorite(restaurant);
      expect(favoriteProvider.favoriteRestaurants.length, 1);
      
      await favoriteProvider.removeFavorite('test-id');
      expect(favoriteProvider.favoriteRestaurants.isEmpty, true);
    });

    test('toggleFavorite should add when not favorite', () {
      final restaurant = FavoriteRestaurant(
        id: 'test-id',
        name: 'Test Restaurant',
        pictureId: 'test-picture',
        city: 'Test City',
        rating: 4.5,
      );

      favoriteProvider.toggleFavorite(restaurant);
      
      expect(favoriteProvider.isFavorite('test-id'), true);
    });

    test('toggleFavorite should remove when already favorite', () {
      final restaurant = FavoriteRestaurant(
        id: 'test-id',
        name: 'Test Restaurant',
        pictureId: 'test-picture',
        city: 'Test City',
        rating: 4.5,
      );

      favoriteProvider.toggleFavorite(restaurant); // Add
      favoriteProvider.toggleFavorite(restaurant); // Remove
      
      expect(favoriteProvider.isFavorite('test-id'), false);
    });
  });
}