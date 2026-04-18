import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:pathing_tool/models/path_data.dart';

class FileService {
  // Export PathData to JSON file
  static Future<bool> exportPath(PathData pathData) async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose where to save the file',
      );

      if (selectedDirectory == null) {
        return false; // User cancelled
      }
    
      final fileName = '${pathData.pathName}.json';
      final filePath = '$selectedDirectory${Platform.pathSeparator}$fileName';

      // Convert to JSON string with pretty formatting
      final jsonString = JsonEncoder.withIndent('  ').convert(pathData.toJson());

      final file = File(filePath);
      await file.writeAsString(jsonString);

      print('Path exported to: $filePath');
      return true;
    } catch (e) {
      print('Error exporting path: $e');
      return false;
    }
  }

  // Import PathData from JSON file
  static Future<PathData?> importPath() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Load Autonomous Path',
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      // Parse JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      if (!isValidPathJson(jsonData)) {
        print('Invalid JSON format');
        return null;
      }
      
      final pathData = PathData.fromJson(jsonData);
      return pathData;
    } catch (e) {
      print('Error importing path: $e');
      return null;
    } 
  }   
      
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