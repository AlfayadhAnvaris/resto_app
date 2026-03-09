// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class ApiService {
  static const baseUrl = "https://restaurant-api.dicoding.dev";
  
  final http.Client client; // tambahkan ini

  ApiService({http.Client? client}) : client = client ?? http.Client(); // constructor

  Future<List<Restaurant>> fetchRestaurants() async {
    final response = await client.get(Uri.parse("$baseUrl/list")); // ganti http. → client.

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List list = data['restaurants'];
      return list.map((e) => Restaurant.fromListJson(e)).toList();
    } else {
      throw Exception("Failed to load restaurants");
    }
  }

  Future<Restaurant> fetchDetail(String id) async {
    final response = await client.get(Uri.parse("$baseUrl/detail/$id")); // ganti http. → client.

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Restaurant.fromDetailJson(data['restaurant']);
    } else {
      throw Exception("Failed to load detail");
    }
  }

  Future<Map<String, dynamic>> getRestaurantDetail(String id) async {
    final response = await client.get( // ganti http. → client.
      Uri.parse("$baseUrl/detail/$id"),
    );
    return jsonDecode(response.body);
  }
}