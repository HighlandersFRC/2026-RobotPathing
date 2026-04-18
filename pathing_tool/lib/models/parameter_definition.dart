enum ParameterType {
  string,
  integer,
  double,
  boolean,
  enumType,
  pathPoints, // Special type for path points
}

class ParameterDefinition {
  final String name;
  final ParameterType type;
  final dynamic defaultValue;
  final List<String>? enumOptions; // For enum type
  final bool required;

  ParameterDefinition({
    required this.name,
    required this.type,
    this.defaultValue,
    this.enumOptions,
    this.required = true,
  });

  factory ParameterDefinition.fromJson(Map<String, dynamic> json) {
    ParameterType type;
    switch (json['type'] as String) {
      case 'string':
        type = ParameterType.string;
        break;
      case 'integer':
        type = ParameterType.integer;
        break;
      case 'double':
        type = ParameterType.double;
        break;
      case 'boolean':
        type = ParameterType.boolean;
        break;
      case 'enum':
        type = ParameterType.enumType;
        break;
      case 'pathPoints':
        type = ParameterType.pathPoints;
        break;
      default:
        type = ParameterType.string;
    }

    return ParameterDefinition(
      name: json['name'] as String,
      type: type,
      defaultValue: json['default'],
      enumOptions: json['options'] != null
          ? (json['options'] as List).map((e) => e as String).toList()
          : null,
      required: json['required'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      if (defaultValue != null) 'default': defaultValue,
      if (enumOptions != null) 'options': enumOptions,
      'required': required,
    };
  }
}
