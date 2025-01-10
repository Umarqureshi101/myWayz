import 'package:flutter/material.dart';  // Import the material design package for Flutter.
import 'package:flutter/services.dart';  // Import the system services package, needed for controlling screen orientation.
import 'package:firebase_core/firebase_core.dart';  // Import Firebase core to initialize Firebase.
import 'package:mywayz/pages/login_page.dart';
import 'package:mywayz/pages/map_page.dart';  // Import the LoginPage widget from your app.
import 'package:mywayz/pages/geopify_map.dart';
import 'package:mywayz/pages/geopify_map_2.0.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensures that Flutter is fully initialized before starting the app.

  // Initialize Firebase asynchronously before the app runs.
  await Firebase.initializeApp();

  // Lock the screen orientation to portrait mode (both up and down).
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,  // Allow the screen to be in portrait mode with the top up.
    DeviceOrientation.portraitDown,  // Allow the screen to be in portrait mode with the top down.
  ]);

  runApp(MyApp());  // Run the MyApp widget to start the app.
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(  // The main MaterialApp widget for your app.
      debugShowCheckedModeBanner: false,  // Hide the "debug" banner on the top of the screen in debug mode.
      title: 'MyWayz',  // Set the title of the app (this appears in the task switcher and on the device).
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => TruckRoutingApp(),
      },  // Set the starting page of the app to be the LoginPage widget.
    );
  }
}
