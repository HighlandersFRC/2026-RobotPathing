import 'command_block.dart';

class SwitchBlock {
  static const String blockType = "Switch";
  
  int index;
  String condition; // various conditions to be met
  Map<String, dynamic> conditionArguments;
  List<CommandBlock> onTrue;
  List<CommandBlock> onFalse;

  SwitchBlock({
    required this.index,
    required this.condition,
    required this.conditionArguments,
    required this.onTrue,
    required this.onFalse,
  });

  // Convert from JSON
  factory SwitchBlock.fromJson(Map<String, dynamic> json) {
    return SwitchBlock(
      index: json['index'] as int,
      condition: json['condition'] as String,
      conditionArguments: json['conditionArguments'] as Map<String, dynamic>,
      onTrue: (json['onTrue'] as List)
          .map((e) => CommandBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
      onFalse: (json['onFalse'] as List)
          .map((e) => CommandBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'type': blockType,
      'condition': condition,
      'conditionArguments': conditionArguments,
      'onTrue': onTrue.map((cb) => cb.toJson()).toList(),
      'onFalse': onFalse.map((cb) => cb.toJson()).toList(),
    };
  }
}