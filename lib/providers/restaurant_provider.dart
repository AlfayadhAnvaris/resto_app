import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';
import '../states/restaurant_state.dart'; // Make sure this path is correct

class RestaurantProvider extends ChangeNotifier {
  final ApiService apiService;

  RestaurantProvider(this.apiService);

  RestaurantState _state = RestaurantLoading();
  RestaurantState get state => _state;

  RestaurantState _detailState = RestaurantLoading();
  RestaurantState get detailState => _detailState;

  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;

  /// =========================
  /// GET LIST RESTAURANT
  /// =========================
  Future<void> getRestaurantList() async {
    try {
      _state = RestaurantLoading();
      notifyListeners();

      _restaurants = await apiService.fetchRestaurants();

      _state = RestaurantLoaded(_restaurants); // This should now be recognized
      notifyListeners();
    } catch (e) {
      _state = RestaurantError(e.toString());
      notifyListeners();
    }
  }

  Future<void> getRestaurantDetail(String id) async {
    try {
      _detailState = RestaurantLoading();
      notifyListeners();

      final restaurant = await apiService.fetchDetail(id);

      _detailState = RestaurantDetailLoaded(restaurant); // This should now be recognized
      notifyListeners();
    } catch (e) {
      _detailState = RestaurantError(e.toString());
      notifyListeners();
    }
  }
}