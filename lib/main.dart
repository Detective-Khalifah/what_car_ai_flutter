import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:what_car_ai_flutter/firebase_options.dart';
import 'package:what_car_ai_flutter/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'What Car AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        primaryColor:
            Color(0xFF6366F1), // Primary color from tailwind.config.js
        // accentColor: Color(0xFF8B5CF6), // Secondary color
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        primaryColor: Color(0xFF111827),
        // accentColor: Color(0xFF8B5CF6),
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          headlineSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
