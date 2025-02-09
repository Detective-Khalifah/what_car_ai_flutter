// import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
// import 'package:flutter/material.dart';

// class ARScene extends StatefulWidget {
//   @override
//   _ARSceneState createState() => _ARSceneState();
// }

// class _ARSceneState extends State<ARScene> {
//   late ArCoreController _controller;

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('AR Scene')),
//       body: ArCoreView(
//         onArCoreViewCreated: (controller) {
//           _controller = controller;
//           _controller.onTrackingChanged.listen((status) {
//             if (status == ArCoreTrackingStatus.TrackingNormal) {
//               print("AR Tracking Ready");
//             } else if (status == ArCoreTrackingStatus.TrackingNone) {
//               print("AR Tracking Lost");
//             }
//           });
//         },
//         child: Positioned(
//           bottom: 100,
//           left: 0,
//           right: 0,
//           child: Container(
//             color: Colors.blue,
//             height: 100,
//             child: Center(
//               child: Text(
//                 "AR Scene",
//                 style: TextStyle(color: Colors.white, fontSize: 24),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
