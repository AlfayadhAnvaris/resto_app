// states/restaurant_state.dart

import '../models/restaurant.dart';

abstract class RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantLoaded extends RestaurantState {
  final List<Restaurant> restaurants;
  RestaurantLoaded(this.restaurants);
}

class RestaurantDetailLoaded extends RestaurantState {
  final Restaurant restaurant;
  RestaurantDetailLoaded(this.restaurant);
}

class RestaurantError extends RestaurantState {
  final String message;
  RestaurantError(this.message);
}