import 'package:flutter/foundation.dart';
import '../models/path_data.dart';
import '../models/robot_profile.dart';
import 'undo_redo_service.dart';

class AppState extends ChangeNotifier {
  // Current autonomous path being edited
  PathData? _currentPath;
  
  // Robot profile
  final RobotProfile robotProfile = RobotProfile.defaultProfile;
  
  // Undo/Redo service
  final UndoRedoService undoRedoService = UndoRedoService();
  
  // Currently selected command index (null if none selected)
  int? _selectedCommandIndex;

  AppState() {
    // Listen to undo/redo changes to trigger UI updates
    undoRedoService.addListener(notifyListeners);
  }

  // Getters
  PathData? get currentPath => _currentPath;
  int? get selectedCommandIndex => _selectedCommandIndex;
  bool get hasPath => _currentPath != null;

  // Create a new autonomous path
  void createNewPath({String name = "Auto"}) {
    _currentPath = PathData.empty();
    _currentPath!.pathName = name;
    _selectedCommandIndex = null;
    undoRedoService.clear();
    notifyListeners();
  }

  // Load an existing path
  void loadPath(PathData pathData) {
    _currentPath = pathData;
    _selectedCommandIndex = null;
    undoRedoService.clear();
    notifyListeners();
  }

  // Select a command by index
  void selectCommand(int? index) {
    _selectedCommandIndex = index;
    notifyListeners();
  }

  // Clear current path
  void clearPath() {
    _currentPath = null;
    _selectedCommandIndex = null;
    undoRedoService.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    undoRedoService.removeListener(notifyListeners);
    undoRedoService.dispose();
    super.dispose();
  }
}