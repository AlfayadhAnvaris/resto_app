

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resto_app/providers/home_provider.dart';
import 'package:resto_app/screens/home_page.dart';
import 'package:resto_app/screens/restaurant_detail_page.dart';
import 'package:resto_app/screens/splash_page.dart';
import 'providers/restaurant_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/reminder_provider.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RestaurantProvider(ApiService()),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoriteProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ReminderProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Restaurant App',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              useMaterial3: true,
              fontFamily: 'Poppins',
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
              cardTheme: const CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
            ),

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              useMaterial3: true,
              fontFamily: 'Poppins',
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.grey[900],
              ),
              cardTheme: const CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
            ),

            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (context) => const SplashPage(),
                  );

                case '/home':
                  return MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  );

                case '/detail':
                  final id = settings.arguments as String?;
                  if (id != null) {
                    return MaterialPageRoute(
                      builder: (context) => RestaurantDetailPage(id: id),
                    );
                  }
                  return MaterialPageRoute(
                    builder: (context) => const Scaffold(
                      body: Center(
                        child: Text('Restaurant ID is required'),
                      ),
                    ),
                  );

                default:
                  return MaterialPageRoute(
                    builder: (context) => const Scaffold(
                      body: Center(
                        child: Text('Page not found'),
                      ),
                    ),
                  );
              }
            },
          );
        },
      ),
    );
  }
}