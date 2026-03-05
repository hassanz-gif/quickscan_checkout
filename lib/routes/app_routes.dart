import 'package:flutter/material.dart';
import '../presentation/camera_scanning_screen/camera_scanning_screen.dart';
import '../presentation/email_collection_screen/email_collection_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String cameraScanning = '/camera-scanning-screen';
  static const String emailCollection = '/email-collection-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const CameraScanningScreen(),
    cameraScanning: (context) => const CameraScanningScreen(),
    emailCollection: (context) => const EmailCollectionScreen(),
    // TODO: Add your other routes here
  };
}
