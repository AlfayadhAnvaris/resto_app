import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/favorite_provider.dart';
import '../states/restaurant_state.dart';
import '../widgets/loading_widget.dart';
import '../models/favorite_restaurant.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  @override
  void initState() {
    super.initState();

    // Fetch data pertama kali
    Future.microtask(() {
      if (mounted) {
        context.read<RestaurantProvider>().getRestaurantList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Restoran"),
        actions: [
          /// FAVORITE PAGE
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favorite');
            },
          ),

          /// SETTINGS PAGE
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),

      body: _buildBody(provider.state),
    );
  }

  Widget _buildBody(RestaurantState state) {
    /// ===============================
    /// LOADING
    /// ===============================
    if (state is RestaurantLoading) {
      return const LoadingWidget();
    }

    /// ===============================
    /// SUCCESS
    /// ===============================
    if (state is RestaurantLoaded) {
      final restaurants = state.restaurants;

      return Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              // Now this works because isFavorite is defined
              final isFavorite = favoriteProvider.isFavorite(restaurant.id);

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                elevation: 2,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "https://restaurant-api.dicoding.dev/images/small/${restaurant.pictureId}",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    restaurant.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(restaurant.city),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${restaurant.rating} ⭐"),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          // Convert Restaurant to FavoriteRestaurant
                          final favoriteRestaurant = FavoriteRestaurant(
                            id: restaurant.id,
                            name: restaurant.name,
                            pictureId: restaurant.pictureId,
                            city: restaurant.city,
                            rating: restaurant.rating,
                          );
                          
                          // Toggle favorite
                          favoriteProvider.toggleFavorite(favoriteRestaurant);
                          
                          // Show feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite 
                                  ? '${restaurant.name} removed from favorites'
                                  : '${restaurant.name} added to favorites',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: restaurant.id,
                    );
                  },
                ),
              );
            },
          );
        },
      );
    }

    /// ===============================
    /// ERROR
    /// ===============================
    if (state is RestaurantError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<RestaurantProvider>().getRestaurantList();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    /// DEFAULT
    return const SizedBox();
  }
}