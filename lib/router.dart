import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:what_car_ai_flutter/screens/about_screen.dart';
import 'package:what_car_ai_flutter/screens/auth/forgot_password_screen.dart';
import 'package:what_car_ai_flutter/screens/auth/login_screen.dart';
import 'package:what_car_ai_flutter/screens/auth/register_screen.dart';
import 'package:what_car_ai_flutter/screens/car_not_found_screen.dart';
import 'package:what_car_ai_flutter/screens/collection_details_screen.dart';
import 'package:what_car_ai_flutter/screens/collections_screen.dart';
import 'package:what_car_ai_flutter/screens/details_screen.dart';
import 'package:what_car_ai_flutter/screens/feedback_screen.dart';
import 'package:what_car_ai_flutter/screens/garage_screens.dart';
import 'package:what_car_ai_flutter/screens/help_screen.dart';
import 'package:what_car_ai_flutter/screens/history_screen.dart';
import 'package:what_car_ai_flutter/screens/premium_screen.dart';
import 'package:what_car_ai_flutter/screens/privacy_screen.dart';
import 'package:what_car_ai_flutter/screens/processing_screen.dart';
import 'package:what_car_ai_flutter/screens/scan_screen.dart';
import 'package:what_car_ai_flutter/screens/settings_screen.dart';
import 'package:what_car_ai_flutter/screens/terms_screen.dart';
import 'package:what_car_ai_flutter/screens/tips_screen.dart';
import 'screens/home_screen.dart'; // Assuming HomeScreen is in screens/home_screen.dart
import 'screens/dashboard/tabs_layout.dart';

final GoRouter router = GoRouter(
  routes: [
    // GoRoute(
    //   path: '/',
    //   redirect: (context, state) => '/dashboard/home',
    // ),
    GoRoute(
      path: '/',
      builder: (context, state) => TabsLayout(),
    ),
    GoRoute(
      path: '/dashboard/home',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) => DetailsScreen(
        carData: '',
        isFresh: false,
      ),
      // context.go('/details', extra: car.id);
    ),
    GoRoute(
      path: '/car-not-found',
      builder: (context, state) {
        final imageUri = state.uri.queryParameters['imageUri'] ?? '';
        return CarNotFoundScreen(imageUri: imageUri);
        //  CarNotFoundScreen(
        // imageUri: state.queryParams['imageUri']!,
        // imageUri: state.uri.queryParameters['imageUri']!,
        // ),
      },
    ),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/collections/:id',
      pageBuilder: (context, state) => MaterialPage(
        child: CollectionDetailsScreen(
          collectionId: '',
          // arguments: state.pathParameters['id'],
          // arguments: state.params['id'],
        ),
      ),
    ),
    GoRoute(
      path: '/garage',
      builder: (context, state) => GarageScreen(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => ScanScreen(),
    ),
    // GoRoute(
    //   path: '/details',
    //   builder: (context, state) => (
    //        DetailsScreen(
    //     carData: state.extra! as String,
    //   )),
    // ),
    GoRoute(
      path: '/car-not-found',
      builder: (context, state) => (CarNotFoundScreen(
        imageUri: '',
      )),
    ),
    // GoRoute(
    //   path: '/process',
    //   builder: (context, state) => ProcessScreen(),
    // ),
    GoRoute(
      path: '/process',
      pageBuilder: (context, state) => MaterialPage(
        child: ProcessingScreen(
          // imageUri: state.queryParams['imageUri']!,
          imageUri: state.uri.queryParameters['imageUri']!,
        ),
      ),
    ),
    GoRoute(
      path: '/tips',
      builder: (context, state) => TipsScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => AboutScreen(),
    ),
    GoRoute(
      path: '/collections',
      builder: (context, state) => CollectionsScreen(),
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) => FeedbackScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => HelpScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => HistoryScreen(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => PremiumScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => PrivacyScreen(),
    ),
    GoRoute(
      path: "/settings",
      builder: (context, state) => SettingsScreen(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => TermsScreen(),
    ),
  ],
);
