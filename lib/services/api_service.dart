import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class ApiService {
  static const baseUrl = "https://restaurant-api.dicoding.dev";

  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await http.get(Uri.parse("$baseUrl/list"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List list = data['restaurants'];

      return list.map((e) => Restaurant.fromListJson(e)).toList();
    } else {
      throw Exception("Failed to load restaurants");
    }
  }

  Future<Restaurant> fetchDetail(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/detail/$id"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Restaurant.fromDetailJson(data['restaurant']);
    } else {
      throw Exception("Failed to load detail");
    }
  }

 Future<Map<String, dynamic>>
    getRestaurantDetail(String id) async {

  final response = await http.get(
    Uri.parse(
        "https://restaurant-api.dicoding.dev/detail/$id"),
  );

  final jsonData =
      jsonDecode(response.body);

  return jsonData;
}
}