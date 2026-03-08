import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resto_app/providers/theme_provider.dart';
import 'package:resto_app/screens/restaurant_detail_page.dart';
import 'screens/restaurant_list_page.dart';
import 'screens/favorite_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// =========================
      /// THEME
      /// =========================
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),

      /// =========================
      /// ROUTING
      /// =========================
      initialRoute: '/',

      routes: {
        '/': (_) => const RestaurantListPage(),
        '/favorite': (_) => const FavoritePage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {

          final args = settings.arguments;

          if (args is String) {
            return MaterialPageRoute(
              builder: (_) =>
                  RestaurantDetailPage(id: args),
            );
          }

          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text(
                  "ID tidak valid",
                ),
              ),
            ),
          );
        }

        return null;
      },
    );
  }
}