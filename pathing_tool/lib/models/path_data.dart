import 'command_block.dart';
import 'switch_block.dart';

class PathData {
  String pathName;
  double sampleRate;
  String pathVersion;
  List<dynamic> commands; // commandBlocks or switchBlocks

  PathData({
    required this.pathName,
    this.sampleRate = 1.0,
    this.pathVersion = "0.0.1",
    required this.commands,
  });                     
                                                                     
                                                                     
                                                                     
  // Create empty path
  factory PathData.empty() {
    return PathData(
      pathName: "Auto",
      commands: [],
    );
  }

  // Convert from JSON
  factory PathData.fromJson(Map<String, dynamic> json) {
    final commandsList = (json['commands'] as List).map((cmdJson) {
      final type = cmdJson['type'] as String;
      if (type == 'Switch') {                
        return SwitchBlock.fromJson(cmdJson as Map<String, dynamic>);
      } else {
        return CommandBlock.fromJson(cmdJson as Map<String, dynamic>);
      }
    }).toList();

    return PathData(
      pathName: json['pathName'] as String,
      sampleRate: (json['sampleRate'] as num).toDouble(),
      pathVersion: json['pathVersion'] as String,
      commands: commandsList,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'pathName': pathName,
      'sampleRate': sampleRate,
      'pathVersion': pathVersion,
      'commands': commands.map((cmd) {
        if (cmd is SwitchBlock) {
          return cmd.toJson();
        } else if (cmd is CommandBlock) {
          return cmd.toJson();
        }
        return {};
      }).toList(),
    };
  }
  
  // Add a command (index automatically updated)
  void addCommand(dynamic command) {
    if (command is CommandBlock || command is SwitchBlock) {
      if (command is CommandBlock) {
        command.index = commands.length;
      } else if (command is SwitchBlock) {
        command.index = commands.length;
      }
      commands.add(command);
    }
  }

  // Remove a command by index
  void removeCommand(int index) {
    if (index >= 0 && index < commands.length) {
      commands.removeAt(index);
      _reindexCommands();
    }
  }
  
  // Reindex all commands after removal
  void _reindexCommands() {
    for (int i = 0; i < commands.length; i++) {
      if (commands[i] is CommandBlock) {
        (commands[i] as CommandBlock).index = i;
      } else if (commands[i] is SwitchBlock) {
        (commands[i] as SwitchBlock).index = i;
      }
    }
  }
}
