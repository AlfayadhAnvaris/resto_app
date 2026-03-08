// test/api_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:resto_app/services/api_service.dart';
import 'package:resto_app/models/restaurant.dart';

void main() {
  late ApiService apiService;

  setUpAll(() {
    apiService = ApiService();
  });

  group('ApiService Tests', () {
    test('fetchRestaurants should return list of restaurants', () async {
      final restaurants = await apiService.fetchRestaurants();
      
      expect(restaurants, isA<List<Restaurant>>());
      expect(restaurants.isNotEmpty, true);
      
      // Check first restaurant has required fields
      final firstRestaurant = restaurants.first;
      expect(firstRestaurant.id, isNotEmpty);
      expect(firstRestaurant.name, isNotEmpty);
      expect(firstRestaurant.city, isNotEmpty);
      expect(firstRestaurant.rating, greaterThan(0));
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('fetchDetail should return single restaurant', () async {
      // First get list to get a valid ID
      final restaurants = await apiService.fetchRestaurants();
      expect(restaurants.isNotEmpty, true);
      
      // Test detail fetch
      final detail = await apiService.fetchDetail(restaurants.first.id);
      
      expect(detail, isA<Restaurant>());
      expect(detail.id, restaurants.first.id);
      expect(detail.name, restaurants.first.name);
      expect(detail.foods, isA<List<String>>());
      expect(detail.drinks, isA<List<String>>());
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('fetchDetail should throw exception for invalid ID', () async {
      expect(
        () => apiService.fetchDetail('invalid-id'),
        throwsException,
      );
    });
  });
}