import 'dart:math';
import 'package:pathing_tool/models/command_block.dart';
import 'package:pathing_tool/models/point_node.dart';
import 'package:pathing_tool/models/robot_profile.dart';

class GeometryUtils {
  static double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  static double radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
  }

  static double get diagonal {
  return sqrt(RobotProfile.defaultProfile.length * RobotProfile.defaultProfile.length + RobotProfile.defaultProfile.width * RobotProfile.defaultProfile.width);
  }

  // Keep angle between -π and π
  static double normalizeAngle(double radians) {
    double angle = radians % (2 * pi);
    if (angle > pi) {
      angle -= 2 * pi;
    } else if (angle < -pi) {
      angle += 2 * pi;
    }
    return angle;
  }

  static double distance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  static double angleBetweenPoints(double x1, double y1, double x2, double y2) {
    return atan2(y2 - y1, x2 - x1);
  }

  static double clamp(double value, double min, double max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }
}

// Helpers for working with command arguments
class CommandUtils {
  // Extract points from command arguments
  static List<PointNode>? getPointsFromCommand(CommandBlock command) {
    if (!command.hasArgument('points')){

     return null;
    }
    final pointsList = command.getArgument<List>('points');
    if (pointsList == null) {
      return null;
    }
    try {
      return pointsList
          .map((p) => PointNode.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error parsing points: $e');
      return null;
    }
  }
  
  // Save points to command arguments
  static void setPointsInCommand(CommandBlock command, List<PointNode> points) {
    command.setArgument('points', points.map((p) => p.toJson()).toList());
  }
  
  static bool hasPoints(CommandBlock command) {
    return command.hasArgument('points') && 
           command.getArgument<List>('points') != null;
  }
}