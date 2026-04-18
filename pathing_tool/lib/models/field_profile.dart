import 'dart:math';

class FieldProfile {

  final double fieldWidth; // meters (for grid)
  final double fieldHeight; // meters (for grid)

  const FieldProfile({
    this.fieldWidth = 17.548,
    this.fieldHeight = 8.052,
  });


  static const FieldProfile defaultProfile = FieldProfile(
    fieldWidth: 17.548,
    fieldHeight: 8.052,
  );
  
}
