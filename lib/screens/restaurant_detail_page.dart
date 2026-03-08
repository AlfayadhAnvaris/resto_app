import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/favorite_provider.dart';
import '../states/restaurant_state.dart';
import '../widgets/loading_widget.dart';
import '../models/favorite_restaurant.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String id;

  const RestaurantDetailPage({
    super.key,
    required this.id,
  });

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        context.read<RestaurantProvider>().getRestaurantDetail(widget.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();
    final state = provider.detailState;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Restoran"),
        actions: [
          /// FAVORITE BUTTON
          if (state is RestaurantDetailLoaded) // Only show when loaded
            _buildFavoriteButton(state.restaurant, favoriteProvider),
        ],
      ),
      body: _buildBody(state),
    );
  }

  /// Extract favorite button to separate method for better readability
  Widget _buildFavoriteButton(restaurant, FavoriteProvider favoriteProvider) {
    // Use Consumer or just watch the provider directly
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, child) {
        final isFavorite = favProvider.isFavorite(restaurant.id);
        
        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
          ),
          onPressed: () async {
            if (isFavorite) {
              await favProvider.removeFavorite(restaurant.id);
              _showSnackBar('${restaurant.name} removed from favorites');
            } else {
              await favProvider.addFavorite(
                FavoriteRestaurant(
                  id: restaurant.id,
                  name: restaurant.name,
                  pictureId: restaurant.pictureId,
                  city: restaurant.city,
                  rating: restaurant.rating,
                ),
              );
              _showSnackBar('${restaurant.name} added to favorites');
            }
          },
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildBody(RestaurantState state) {
    if (state is RestaurantLoading) {
      return const LoadingWidget();
    }

    if (state is RestaurantDetailLoaded) {
      final restaurant = state.restaurant;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "https://restaurant-api.dicoding.dev/images/medium/${restaurant.pictureId}",
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// NAME
            Text(
              restaurant.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 6),

            /// LOCATION
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "${restaurant.city} • ${restaurant.address}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            /// RATING
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  "${restaurant.rating} ⭐",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// DESCRIPTION
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(restaurant.description),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// =========================
            /// MENU MAKANAN
            /// =========================
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Menu Makanan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...restaurant.foods.map(
                      (food) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.restaurant_menu, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(food)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// =========================
            /// MENU MINUMAN
            /// =========================
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Menu Minuman",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...restaurant.drinks.map(
                      (drink) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.local_drink, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text(drink)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is RestaurantError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<RestaurantProvider>().getRestaurantDetail(widget.id);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }
}