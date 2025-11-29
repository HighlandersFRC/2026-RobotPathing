import 'dart:math';

class RobotProfile {
  final double length; // meters
  final double width; // meters
  final double maxVelocity; // m/s
  final double maxAcceleration; // m/s²
  final double maxCentripetalAcceleration; // m/s²
  final double fieldWidth; // meters (for grid)
  final double fieldHeight; // meters (for grid)

  const RobotProfile({
    required this.length,
    required this.width,
    required this.maxVelocity,
    required this.maxAcceleration,
    required this.maxCentripetalAcceleration,
    this.fieldWidth = 10.0,
    this.fieldHeight = 10.0,
  });

 
  static const RobotProfile defaultProfile = RobotProfile(
    length: 0.9, // 0.9 meters
    width: 0.8, // 0.8 meters 
    maxVelocity: 4.0, // 4 m/s
    maxAcceleration: 3.0, // 3 m/s²
    maxCentripetalAcceleration: 2.5, // 2.5 m/s²
    fieldWidth: 10.0,
    fieldHeight: 10.0,
  );

  
 double get diagonal {
  return sqrt(length * length + width * width);
}
}