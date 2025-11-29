import 'point_node.dart';

class CommandBlock {
  int? index; // Optional 
  String type; 
  List<String> commands; // types of commands
  Map<String, dynamic> arguments;

  CommandBlock({
    this.index,
    this.type = "CommandBlock",
    required this.commands,
    required this.arguments,
  });

  // pathing commands with points
  factory CommandBlock.withPoints({
    int? index,
    required String commandName,
    required List<PointNode> points,
  }) {
    return CommandBlock(
      index: index,
      commands: [commandName],
      arguments: {
        'points': points.map((p) => p.toJson()).toList(),
      },
    );
  }

  // Convert from JSON
  factory CommandBlock.fromJson(Map<String, dynamic> json) {
    return CommandBlock(
      index: json['index'] as int?,
      type: json['type'] as String? ?? "CommandBlock",
      commands: (json['commands'] as List).map((e) => e as String).toList(),
      arguments: json['arguments'] as Map<String, dynamic>,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type,
      'commands': commands,
      'arguments': arguments,
    };
    
    if (index != null) {
      json['index'] = index;
    }
    
    return json;
  }

  // If the command has points then get them
  List<PointNode>? getPoints() {
    if (arguments.containsKey('points')) {
      final pointsList = arguments['points'] as List;
      return pointsList.map((p) => PointNode.fromJson(p as Map<String, dynamic>)).toList();
    }
    return null;
  }

  // Update points
  void setPoints(List<PointNode> points) {
    arguments['points'] = points.map((p) => p.toJson()).toList();
  }
}