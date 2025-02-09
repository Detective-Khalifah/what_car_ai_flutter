// import 'package:flutter/material.dart';
// import 'package:vision_camera/vision_camera.dart';
// import 'package:vision_camera_platform_interface/vision_camera_platform_interface.dart';

// class ARCameraView extends StatefulWidget {
//   @override
//   _ARCameraViewState createState() => _ARCameraViewState();
// }

// class _ARCameraViewState extends State<ARCameraView> {
//   late VisionCameraController _controller;
//   List<Map<String, dynamic>> detectedFeatures = [];

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _initCamera() async {
//     _controller = VisionCameraController(
//       ResolutionPreset.highest,
//       sensorOrientation: 90,
//     );
//     await _controller.initialize();
//     _controller.setFrameProcessor((frame) async {
//       // Detect basic shapes and edges
//       setState(() {
//         detectedFeatures = [
//           {
//             'type': 'car_body',
//             'bounds': {
//               'x': frame.width * 0.2,
//               'y': frame.height * 0.2,
//               'width': frame.width * 0.6,
//               'height': frame.height * 0.6,
//             },
//           },
//         ];
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('AR Camera View')),
//       body: Stack(
//         children: [
//           VisionCamera(
//             controller: _controller,
//             child: Container(),
//           ),
//           _renderOverlays(),
//         ],
//       ),
//     );
//   }

//   Widget _renderOverlays() {
//     return Positioned.fill(
//       child: CustomPaint(
//         painter: OverlayPainter(detectedFeatures: detectedFeatures),
//       ),
//     );
//   }
// }

// class OverlayPainter extends CustomPainter {
//   final List<Map<String, dynamic>> detectedFeatures;

//   OverlayPainter({required this.detectedFeatures});

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.green
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;

//     for (var feature in detectedFeatures) {
//       var bounds = feature['bounds'];
//       Rect rect = Rect.fromLTWH(
//         bounds['x'],
//         bounds['y'],
//         bounds['width'],
//         bounds['height'],
//       );
//       canvas.drawRect(rect, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
