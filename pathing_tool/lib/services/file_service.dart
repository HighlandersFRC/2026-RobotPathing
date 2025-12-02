import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:pathing_tool/models/path_data.dart';

class FileService {
  // Export PathData to JSON file
  static Future<bool> exportPath(PathData pathData) async {
    try {
      // Get save location from user
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Autonomous Path',
        fileName: '${pathData.pathName}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputPath == null) {
        return false; // User cancelled
      }

      // Convert to JSON string with pretty formatting
      final jsonString = JsonEncoder.withIndent('  ').convert(pathData.toJson());

      // Write to file
      final file = File(outputPath);
      await file.writeAsString(jsonString);

      return true;
    } catch (e) {
      print('Error exporting path: $e');
      return false;
    }
  }

  // Import PathData from JSON file
  static Future<PathData?> importPath() async {
    try {
      // Let user pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Load Autonomous Path',
      );

      if (result == null || result.files.single.path == null) {
        return null; // User cancelled
      }

      // Read file content
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      // Parse JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final pathData = PathData.fromJson(jsonData);

      return pathData;
    } catch (e) {
      print('Error importing path: $e');
      return null;
    }
  }

  // Validate JSON structure before importing
  static bool isValidPathJson(Map<String, dynamic> json) {
    try {
      return json.containsKey('pathName') &&
          json.containsKey('commands') &&
          json['commands'] is List;
    } catch (e) {
      return false;
    }
  }
}