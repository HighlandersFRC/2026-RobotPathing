import 'dart:math';

class RobotProfile {
  final double length; // meters
  final double width; // meters
  final double maxVelocity; // m/s
  final double maxAcceleration; // m/s²
  final double maxCentripetalAcceleration; // m/s²

  const RobotProfile({
    required this.length,
    required this.width,
    required this.maxVelocity,
    required this.maxAcceleration,
    required this.maxCentripetalAcceleration,
  });

 
  static const RobotProfile defaultProfile = RobotProfile(
    length: 0.8128, 
    width: 0.6604, 
    maxVelocity: 4.0,
    maxAcceleration: 3.0, 
    maxCentripetalAcceleration: 2.5, 
  );

}
