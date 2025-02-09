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
import 'package:what_car_ai_flutter/screens/terms_screen.dart';
import 'package:what_car_ai_flutter/screens/tips_screen.dart';
import 'screens/home_screen.dart'; // Assuming HomeScreen is in screens/home_screen.dart
import 'screens/dashboard/tabs_layout.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/dashboard/home',
    ),
    GoRoute(
      path: '/dashboard/home',
      builder: (context, state) => TabsLayout(),
    ),
    // GoRoute(
    //   path: '/dashboard/home',
    //   pageBuilder: (context, state) => MaterialPage(child: HomeScreen()),
    // ),
    GoRoute(
      path: '/details',
      pageBuilder: (context, state) => MaterialPage(
          child: DetailsScreen(
        carData: '',
        isFresh: false,
      )),
      // context.go('/details', extra: car.id);
    ),
    GoRoute(
      path: '/car-not-found',
      builder: (context, state) {
        final imageUri = state.uri.queryParameters['imageUri'] ?? '';
        return CarNotFoundScreen(imageUri: imageUri);
        // child: CarNotFoundScreen(
        // imageUri: state.queryParams['imageUri']!,
        // imageUri: state.uri.queryParameters['imageUri']!,
        // ),
      },
    ),
    GoRoute(
      path: '/auth/forgot-password',
      pageBuilder: (context, state) =>
          MaterialPage(child: ForgotPasswordScreen()),
    ),
    GoRoute(
      path: '/auth/login',
      pageBuilder: (context, state) => MaterialPage(child: LoginScreen()),
    ),
    GoRoute(
      path: '/auth/register',
      pageBuilder: (context, state) => MaterialPage(child: RegisterScreen()),
    ),
    GoRoute(
      path: '/collections/:id',
      pageBuilder: (context, state) => MaterialPage(
        child: CollectionDetailsScreen(
            // arguments: state.pathParameters['id'],
            // arguments: state.params['id'],
            ),
      ),
    ),
    GoRoute(
      path: '/garage',
      pageBuilder: (context, state) => MaterialPage(child: GarageScreen()),
    ),
    GoRoute(
      path: '/scan',
      pageBuilder: (context, state) => MaterialPage(child: ScanScreen()),
    ),
    // GoRoute(
    //   path: '/details',
    //   pageBuilder: (context, state) => MaterialPage(
    //       child: DetailsScreen(
    //     carData: state.extra! as String,
    //   )),
    // ),
    GoRoute(
      path: '/car-not-found',
      pageBuilder: (context, state) => MaterialPage(
          child: CarNotFoundScreen(
        imageUri: '',
      )),
    ),
    // GoRoute(
    //   path: '/process',
    //   pageBuilder: (context, state) => MaterialPage(child: ProcessScreen()),
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
      pageBuilder: (context, state) => MaterialPage(child: TipsScreen()),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => MaterialPage(child: AboutScreen()),
    ),
    GoRoute(
      path: '/collections',
      pageBuilder: (context, state) => MaterialPage(child: CollectionsScreen()),
    ),
    GoRoute(
      path: '/feedback',
      pageBuilder: (context, state) => MaterialPage(child: FeedbackScreen()),
    ),
    GoRoute(
      path: '/help',
      pageBuilder: (context, state) => MaterialPage(child: HelpScreen()),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (context, state) => MaterialPage(child: HistoryScreen()),
    ),
    GoRoute(
      path: '/premium',
      pageBuilder: (context, state) => MaterialPage(child: PremiumScreen()),
    ),
    GoRoute(
      path: '/privacy',
      pageBuilder: (context, state) => MaterialPage(child: PrivacyScreen()),
    ),
    GoRoute(
      path: '/terms',
      pageBuilder: (context, state) => MaterialPage(child: TermsScreen()),
    ),
  ],
);
