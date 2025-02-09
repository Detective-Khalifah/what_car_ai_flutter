# what_car_ai_flutter

What Car AI is a mobile application designed to help users identify cars from photos using artificial intelligence. The app leverages the Claude AI API to process images and provide detailed information about the identified vehicle, including its make, model, specifications, rarity insights, and historical context.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Structure
/lib/
├── main.dart
├── router.dart
├── screens/
│   ├── auth/
│   │   ├── forgot_password_screen.dart
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── collection_details_screen.dart
│   ├── details_screen.dart
│   ├── car_not_found_screen.dart
│   ├── process_screen.dart
│   ├── tips_screen.dart
│   ├── about_screen.dart
│   ├── collections_screen.dart
│   ├── feedback_screen.dart
│   ├── help_screen.dart
│   ├── history_screen.dart
│   ├── premium_screen.dart
│   ├── privacy_screen.dart
│   ├── settings_screen.dart
│   ├── scan_screen.dart
│   └── home_screen.dart
├── components/
│   ├── car_card.dart
│   ├── feature_info_card.dart
│   └── ar_camera_view.dart
├── services/
│   ├── auth_service.dart
│   ├── scan_service.dart
│   └── storage_service.dart
├── providers/
│   ├── data_provider.dart
│   ├── tab_state_provider.dart
│   └── auth_provider.dart
├── models/
│   └── car.dart
├── utils/
│   ├── constants.dart
│   └── utilities.dart