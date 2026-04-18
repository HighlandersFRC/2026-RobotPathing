import 'package:flutter/foundation.dart';

// Base class for all undoable actions
abstract class UndoableAction {
  void execute();
  void undo();
  String get description;
}

class UndoRedoService extends ChangeNotifier {
  final List<UndoableAction> _undoStack = [];
  final List<UndoableAction> _redoStack = [];
  
  static const int maxStackSize = 100; // Limit stack size to prevent memory issues

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  // Execute an action and add it to the undo stack
  void execute(UndoableAction action) {
    action.execute();
    _undoStack.add(action);
    _redoStack.clear(); // Clear redo stack when new action is performed
    
    // Limit stack size
    if (_undoStack.length > maxStackSize) {
      _undoStack.removeAt(0);
    }
    
    notifyListeners();
  }

  // Undo the last action
  void undo() {
    if (!canUndo) return;
    
    final action = _undoStack.removeLast();
    action.undo();
    _redoStack.add(action);
    
    notifyListeners();
  }

  // Redo the last undone action
  void redo() {
    if (!canRedo) return;
    
    final action = _redoStack.removeLast();
    action.execute();
    _undoStack.add(action);
    
    notifyListeners();
  }

  // Clear all history
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }

  // Get description of next undo action
  String? get undoDescription {
    if (!canUndo) return null;
    return _undoStack.last.description;
  }

  // Get description of next redo action
  String? get redoDescription {
    if (!canRedo) return null;
    return _redoStack.last.description;
  }
}