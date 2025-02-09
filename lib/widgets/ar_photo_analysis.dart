// import 'package:flutter/material.dart';
// import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart'
//     show ArCoreController, ArCoreView;

// class ARPhotoAnalysis extends StatefulWidget {
//   final String imageUri;

//   ARPhotoAnalysis({required this.imageUri});

//   @override
//   _ARPhotoAnalysisState createState() => _ARPhotoAnalysisState();
// }

// class _ARPhotoAnalysisState extends State<ARPhotoAnalysis> {
//   late ArCoreController _controller;
//   List<Map<String, dynamic>> markers = [];

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('AR Photo Analysis')),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.network(
//               widget.imageUri,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: ArCoreView(
//               onArCoreViewCreated: (controller) {
//                 _controller = controller;
//                 _controller.onAnchorAdded.listen((anchor) {
//                   setState(() {
//                     markers.add({
//                       'position': anchor.position,
//                       'label': 'Headlights',
//                       'description': 'LED Matrix Headlights',
//                     });
//                   });
//                 });
//               },
//               child: Stack(
//                 children: markers.map((marker) {
//                   return Positioned(
//                     top: marker['position'][1],
//                     left: marker['position'][0],
//                     child: Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: Center(
//                         child: Text(
//                           marker['label'],
//                           style: TextStyle(color: Colors.white, fontSize: 12),
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
