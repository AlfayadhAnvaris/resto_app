// test/api_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:resto_app/services/api_service.dart';
import 'package:resto_app/models/restaurant.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late ApiService apiService;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService(client: mockClient);
  });

  // Dummy JSON response sesuai struktur API Dicoding
  const fakeListJson = '''
  {
    "error": false,
    "message": "success",
    "count": 1,
    "restaurants": [
      {
        "id": "rqdv5juczeskfw1e867",
        "name": "Melting Pot",
        "description": "Tempat makan enak",
        "pictureId": "14",
        "city": "Medan",
        "rating": 4.2
      }
    ]
  }
  ''';

  const fakeDetailJson = '''
  {
    "error": false,
    "message": "success",
    "restaurant": {
      "id": "rqdv5juczeskfw1e867",
      "name": "Melting Pot",
      "description": "Tempat makan enak",
      "city": "Medan",
      "address": "Jl. Belimbing No.1",
      "pictureId": "14",
      "rating": 4.2,
      "menus": {
        "foods": [{"name": "Nasi Goreng"}],
        "drinks": [{"name": "Es Teh"}]
      },
      "customerReviews": []
    }
  }
  ''';

  group('ApiService Tests', () {
    test('fetchRestaurants should return list of restaurants', () async {
      when(mockClient.get(Uri.parse('https://restaurant-api.dicoding.dev/list')))
          .thenAnswer((_) async => http.Response(fakeListJson, 200));

      final restaurants = await apiService.fetchRestaurants();

      expect(restaurants, isA<List<Restaurant>>());
      expect(restaurants.isNotEmpty, true);
      expect(restaurants.first.id, 'rqdv5juczeskfw1e867');
      expect(restaurants.first.name, 'Melting Pot');
      expect(restaurants.first.city, 'Medan');
      expect(restaurants.first.rating, greaterThan(0));
    });

    test('fetchDetail should return single restaurant', () async {
      const id = 'rqdv5juczeskfw1e867';

      when(mockClient.get(Uri.parse('https://restaurant-api.dicoding.dev/detail/$id')))
          .thenAnswer((_) async => http.Response(fakeDetailJson, 200));

      final detail = await apiService.fetchDetail(id);

      expect(detail, isA<Restaurant>());
      expect(detail.id, id);
      expect(detail.name, 'Melting Pot');
      expect(detail.foods, isA<List<String>>());
      expect(detail.drinks, isA<List<String>>());
    });

    test('fetchDetail should throw exception for invalid ID', () async {
      const invalidId = 'invalid-id';

      when(mockClient.get(Uri.parse('https://restaurant-api.dicoding.dev/detail/$invalidId')))
          .thenAnswer((_) async => http.Response('{"error": true}', 404));

      expect(() => apiService.fetchDetail(invalidId), throwsException);
    });

    test('fetchRestaurants should throw exception on server error', () async {
      when(mockClient.get(Uri.parse('https://restaurant-api.dicoding.dev/list')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      expect(() => apiService.fetchRestaurants(), throwsException);
    });
  });
}