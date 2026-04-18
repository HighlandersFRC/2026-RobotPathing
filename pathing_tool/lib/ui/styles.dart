import 'package:flutter/material.dart';

class AppStyles {
  // Colors
  static const Color primaryColor = Color(0xFF2196F3); 
  static const Color secondaryColor =  Color.fromARGB(217, 43, 200, 228);
  static const Color accentColor = Color(0xFF03A9F4); 
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color gridBackgroundColor = Color(0xFFFFFFFF); 
  static const Color gridLineColor = Color(0xFFE0E0E0); 
  static const Color gridMajorLineColor = Color(0xFFBDBDBD);
  static const Color robotColor = Color(0xFF4CAF50); 
  static const Color robotFrontIndicator = Color(0xFFFF5722); 
  static const Color pointColor = Color(0xFF2196F3); 
  static const Color selectedPointColor = Color(0xFFFF9800); 
  static const Color pathLineColor = Color(0xFF9C27B0); 
  static const Color errorColor = Color(0xFFF44336); 

  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.black54,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double pointRadius = 8.0;
  static const double robotIndicatorRadius = 4.0;
  
  // Grid Settings
  static const double gridMinorSpacing = 0.5; // meters
  static const double gridMajorSpacing = 1.0; // meters
  static const double gridLineWidth = 1.0;
  static const double gridMajorLineWidth = 2.0;
  
  // Shadows
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );
  
  // Borders
  static final BorderRadius defaultBorderRadius = BorderRadius.circular(borderRadius);
  
  static final Border defaultBorder = Border.all(
    color: gridLineColor,
    width: 1.0,
  );
}