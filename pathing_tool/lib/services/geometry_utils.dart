import 'dart:math';

class GeometryUtils {
  // Convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  // Convert radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
  }


  // Normalize angle to be within -pi to pi range
  static double normalizeAngle(double radians) {
    double angle = radians % (2 * pi);
    if (angle > pi) {
      angle -= 2 * pi;
    } else if (angle < -pi) {
      angle += 2 * pi;
    }
    return angle;
  }

  // Calculate distance between two points
  static double distance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  // Calculate angle between two points (in radians)
  static double angleBetweenPoints(double x1, double y1, double x2, double y2) {
    return atan2(y2 - y1, x2 - x1);
  }

  // Clamp a value between min and max
  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}