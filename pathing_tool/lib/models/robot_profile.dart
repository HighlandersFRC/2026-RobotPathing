// import 'dart:math';

// class RobotProfile {
//   final double length; // meters
//   final double width; // meters
//   final double maxVelocity; // m/s
//   final double maxAcceleration; // m/s²
//   final double maxCentripetalAcceleration; // m/s²

//   const RobotProfile({
//     required this.length,
//     required this.width,
//     required this.maxVelocity,
//     required this.maxAcceleration,
//     required this.maxCentripetalAcceleration,
//   });

 
//   static const RobotProfile defaultProfile = RobotProfile(
//     length: 0.8128, 
//     width: 0.6604, 
//     maxVelocity: 4.0,
//     maxAcceleration: 3.0, 
//     maxCentripetalAcceleration: 2.5, 
//   );

// }
import 'dart:math';
import 'dart:convert';
import 'package:pathing_tool/models/command_definition.dart';
import 'package:pathing_tool/models/parameter_definition.dart';

class RobotProfile {
  final double length;
  final double width;
  final double maxVelocity;
  final double maxAcceleration;
  final double maxCentripetalAcceleration;
  final double fieldWidth;
  final double fieldHeight;
  final List<CommandDefinition> availableCommands;

  const RobotProfile({
    required this.length,
    required this.width,
    required this.maxVelocity,
    required this.maxAcceleration,
    required this.maxCentripetalAcceleration,
    this.fieldWidth = 10.0,
    this.fieldHeight = 10.0,
    required this.availableCommands,
  });

  double get diagonal {
    return sqrt(length * length + width * width);
  }

  // Hard-coded default for POC
  static final RobotProfile defaultProfile = RobotProfile(
    length: 0.9,
    width: 0.8,
    maxVelocity: 4.0,
    maxAcceleration: 3.0,
    maxCentripetalAcceleration: 2.5,
    fieldWidth: 10.0,
    fieldHeight: 10.0,
    availableCommands: [
      CommandDefinition(
        name: 'PurePursuitFollowPath',
        displayName: 'Pure Pursuit Path',
        description: 'Follow a path using pure pursuit algorithm',
        icon: 'route',
        parameters: [
          ParameterDefinition(
            name: 'points',
            type: ParameterType.pathPoints,
          ),
          ParameterDefinition(
            name: 'lookahead',
            type: ParameterType.double,
            defaultValue: 0.5,
            required: false,
          ),
          ParameterDefinition(
            name: 'reversed',
            type: ParameterType.boolean,
            defaultValue: false,
            required: false,
          ),
        ],
      ),
      CommandDefinition(
        name: 'ElevatorToHeight',
        displayName: 'Elevator Control',
        description: 'Move elevator to specified height',
        icon: 'elevator',
        parameters: [
          ParameterDefinition(
            name: 'height',
            type: ParameterType.double,
          ),
          ParameterDefinition(
            name: 'speed',
            type: ParameterType.double,
            defaultValue: 0.8,
            required: false,
          ),
        ],
      ),
      CommandDefinition(
        name: 'IntakeControl',
        displayName: 'Intake Control',
        description: 'Control intake mechanism',
        icon: 'power',
        parameters: [
          ParameterDefinition(
            name: 'state',
            type: ParameterType.enumType,
            enumOptions: ['intake', 'outtake', 'stop', 'l1'],
          ),
          ParameterDefinition(
            name: 'timeout',
            type: ParameterType.double,
            defaultValue: 1.0,
            required: false,
          ),
        ],
      ),
    ],
  );

  // Load from JSON (for future use)
  factory RobotProfile.fromJson(Map<String, dynamic> json) {
    return RobotProfile(
      length: (json['length'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      maxVelocity: (json['maxVelocity'] as num).toDouble(),
      maxAcceleration: (json['maxAcceleration'] as num).toDouble(),
      maxCentripetalAcceleration: (json['maxCentripetalAcceleration'] as num).toDouble(),
      fieldWidth: (json['fieldWidth'] as num?)?.toDouble() ?? 10.0,
      fieldHeight: (json['fieldHeight'] as num?)?.toDouble() ?? 10.0,
      availableCommands: (json['commands'] as List)
          .map((c) => CommandDefinition.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'width': width,
      'maxVelocity': maxVelocity,
      'maxAcceleration': maxAcceleration,
      'maxCentripetalAcceleration': maxCentripetalAcceleration,
      'fieldWidth': fieldWidth,
      'fieldHeight': fieldHeight,
      'commands': availableCommands.map((c) => c.toJson()).toList(),
    };
  }

  // Find command by name
  CommandDefinition? getCommandDefinition(String name) {
    try {
      return availableCommands.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }
}