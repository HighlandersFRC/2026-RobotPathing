import 'package:pathing_tool/models/parameter_definition.dart';

class CommandDefinition {
  final String name; // Internal name (e.g., "PurePursuitFollowPath")
  final String displayName; // UI name (e.g., "Pure Pursuit Path")
  final String? description;
  final String icon; // Icon name from Icons
  final List<ParameterDefinition> parameters;

  CommandDefinition({
    required this.name,
    required this.displayName,
    this.description,
    this.icon = 'settings',
    required this.parameters,
  });

  // Check if this command needs path points
  bool get requiresPathPoints {
    return parameters.any((p) => p.type == ParameterType.pathPoints);
  }

  // Get all non-path parameters
  List<ParameterDefinition> get nonPathParameters {
    return parameters.where((p) => p.type != ParameterType.pathPoints).toList();
  }

  factory CommandDefinition.fromJson(Map<String, dynamic> json) {
    return CommandDefinition(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String? ?? 'settings',
      parameters: (json['parameters'] as List)
          .map((p) => ParameterDefinition.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      if (description != null) 'description': description,
      'icon': icon,
      'parameters': parameters.map((p) => p.toJson()).toList(),
    };
  }
}