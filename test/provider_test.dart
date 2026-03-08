// test/provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:resto_app/providers/restaurant_provider.dart';
import 'package:resto_app/services/api_service.dart';
import 'package:resto_app/models/restaurant.dart';
import 'package:resto_app/states/restaurant_state.dart';

@GenerateMocks([ApiService])
import 'provider_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late RestaurantProvider restaurantProvider;

  setUp(() {
    mockApiService = MockApiService();
    restaurantProvider = RestaurantProvider(mockApiService);
  });

  group('RestaurantProvider Tests', () {
    test('Initial state should be RestaurantLoading', () {
      expect(restaurantProvider.state, isA<RestaurantLoading>());
    });

    test('Initial restaurants list should be empty', () {
      expect(restaurantProvider.restaurants, isEmpty);
    });

    test('getRestaurantList should return RestaurantLoaded on success', () async {
      // Mock data
      final mockRestaurants = [
        Restaurant(
          id: '1',
          name: 'Test Restaurant 1',
          description: 'Description 1',
          city: 'City 1',
          address: 'Address 1',
          pictureId: 'pic1',
          rating: 4.5,
          foods: ['Food 1'],
          drinks: ['Drink 1'],
        ),
      ];

      // Setup mock
      when(mockApiService.fetchRestaurants()).thenAnswer((_) async => mockRestaurants);
      
      // Execute
      await restaurantProvider.getRestaurantList();
      
      // Verify
      expect(restaurantProvider.state, isA<RestaurantLoaded>());
      final loadedState = restaurantProvider.state as RestaurantLoaded;
      expect(loadedState.restaurants.length, 1);
      expect(loadedState.restaurants.first.name, 'Test Restaurant 1');
    });

    test('getRestaurantList should return RestaurantError on failure', () async {
      // Setup mock to throw error
      when(mockApiService.fetchRestaurants()).thenThrow(Exception('Network error'));
      
      // Execute
      await restaurantProvider.getRestaurantList();
      
      // Verify
      expect(restaurantProvider.state, isA<RestaurantError>());
      final errorState = restaurantProvider.state as RestaurantError;
      expect(errorState.message, contains('Exception: Network error'));
    });
  });
}