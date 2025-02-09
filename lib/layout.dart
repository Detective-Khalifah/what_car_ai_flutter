// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:bottom_sheet/bottom_sheet.dart';
// import 'package:what_car_ai_flutter/contexts/data_context.dart';
// import 'package:what_car_ai_flutter/screens/dashboard/tabs_layout.dart';
// import 'package:what_car_ai_flutter/screens/details_screen.dart';
// import 'package:what_car_flutter/providers/data_provider.dart';
// import 'package:what_car_flutter/providers/tab_state_provider.dart';
// import 'package:what_car_flutter/screens/dashboard/tabs_layout.dart';
// import 'package:what_car_flutter/screens/scan_screen.dart';
// import 'package:what_car_flutter/screens/details_screen.dart';
// import 'package:what_car_flutter/screens/car_not_found_screen.dart';
// import 'package:what_car_flutter/screens/process_screen.dart';
// import 'package:what_car_flutter/screens/tips_screen.dart';

// class Layout extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         Provider<DataProvider>.value(value: DataProvider()),
//         Provider<TabStateProvider>.value(value: TabStateProvider()),
//       ],
//       child: MaterialApp(
//         theme: ThemeData(
//           primaryColor: Color(0xFF6366F1),
//           // accentColor: Color(0xFF8B5CF6),
//           scaffoldBackgroundColor: Colors.white,
//         ),
//         darkTheme: ThemeData(
//           primaryColor: Color(0xFF111827),
//           // accentColor: Color(0xFF8B5CF6),
//           scaffoldBackgroundColor: Colors.black,
//           textTheme: TextTheme(
//             headlineSmall: TextStyle(color: Colors.white),
//             bodyLarge: TextStyle(color: Colors.white),
//           ),
//         ),
//         home: TabsLayout(),
//         routes: {
//           '/scan': (context) => ScanScreen(),
//           '/details': (context) => DetailsScreen(),
//           '/car-not-found': (context) => CarNotFoundScreen(),
//           '/process': (context) => ProcessScreen(),
//           '/tips': (context) => TipsScreen(),
//         },
//       ),
//     );
//   }
// }
