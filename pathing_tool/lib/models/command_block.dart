// import 'point_node.dart';

// class CommandBlock {
//   int index;
//   String type; 
//   List<String> commands; // types of commands
//   Map<String, dynamic> arguments;

//   CommandBlock({
//     required this.index,
//     this.type = "CommandBlock",
//     required this.commands,
//     required this.arguments,
//   });

//   // pathing commands with points
//   factory CommandBlock.withPoints({
//     int index = 0,
//     required String commandName,
//     required List<PointNode> points,
//   }) {
//     return CommandBlock(
//       index: index,
//       commands: [commandName],
//       arguments: {
//         'points': points.map((p) => p.toJson()).toList(),
//       },
//     );
//   }

//   // Convert from JSON
//   factory CommandBlock.fromJson(Map<String, dynamic> json) {
//     return CommandBlock(
//       index: json['index'] as int? ?? 0, // Default to 0 if missing
//       type: json['type'] as String? ?? "CommandBlock",
//       commands: (json['commands'] as List).map((e) => e as String).toList(),
//       arguments: json['arguments'] as Map<String, dynamic>,
//     );
//   }

//   // Convert to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'index': index,
//       'type': type,
//       'commands': commands,
//       'arguments': arguments,
//     };
//   }

//   // If the command has points then get them
//   List<PointNode>? getPoints() {
//     if (arguments.containsKey('points')) {
//       final pointsList = arguments['points'] as List;
//       return pointsList.map((p) => PointNode.fromJson(p as Map<String, dynamic>)).toList();
//     }
//     return null;
//   }

//   // Update points
//   void setPoints(List<PointNode> points) {
//     arguments['points'] = points.map((p) => p.toJson()).toList();
//   }
// }
import 'point_node.dart';

class CommandBlock {
  int index;
  String type; 
  List<String> commands; // command names to execute
  Map<String, dynamic> arguments; // any data the commands need

  CommandBlock({
    required this.index,
    this.type = "CommandBlock",
    required this.commands,
    required this.arguments,
  });

  factory CommandBlock.fromJson(Map<String, dynamic> json) {
    return CommandBlock(
      index: json['index'] as int? ?? 0,
      type: json['type'] as String? ?? "CommandBlock",
      commands: (json['commands'] as List).map((e) => e as String).toList(),
      arguments: json['arguments'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'type': type,
      'commands': commands,
      'arguments': arguments,
    };
  }

  // Get any argument by key
  T? getArgument<T>(String key) {
    return arguments[key] as T?;
  }
  
  // Set any argument
  void setArgument(String key, dynamic value) {
    arguments[key] = value;
  }
  
  bool hasArgument(String key) {
    return arguments.containsKey(key);
  }
  
  void removeArgument(String key) {
    arguments.remove(key);
  }
}



 