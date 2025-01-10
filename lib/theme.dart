// Importing the 'dart:ui' package to access low-level graphical and UI features.
import 'dart:ui';

// Importing Cupertino package for iOS-style widgets, although it's not used here, it might be used later for specific styling.
import 'package:flutter/cupertino.dart';

// CustomTheme class to define various colors and gradients for the app's theme.
class CustomTheme {
  // Private constructor to prevent instantiation of this class since it only holds static constants.
  const CustomTheme();

  // Defining the starting color for the login gradient (light orange).
  // Defining the starting color for the login gradient (light blue).
  static const Color loginGradientStart = Color(0xFF64b6ff); // Light blue

// Defining the ending color for the login gradient (dark blue).
  static const Color loginGradientEnd = Color(0xFF1e3c72); // Dark blue
  // Defining white color for general UI elements.
  static const Color white = Color(0xFFFFFFFF);

  // Defining black color for text and other elements.
  static const Color black = Color(0xFF000000);

  // Defining a primary gradient with the start and end colors, and its properties.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[loginGradientStart, loginGradientEnd],  // Colors for the gradient
    stops: <double>[0.0, 1.0],  // Stops define the color distribution along the gradient
    begin: Alignment.topCenter,  // Gradient starts from the top center
    end: Alignment.bottomCenter,  // Gradient ends at the bottom center
  );
}
