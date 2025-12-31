import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pathing_tool/state/app_state.dart';
import 'package:pathing_tool/models/point_node.dart';
import 'package:pathing_tool/models/command_block.dart';
import 'package:pathing_tool/widgets/top_bar.dart';
import 'package:pathing_tool/widgets/grid_canvas.dart';
import 'package:pathing_tool/widgets/point_editor.dart';
import 'package:pathing_tool/widgets/command_list.dart';
import 'package:pathing_tool/ui/styles.dart';

class PathEditorPage extends StatefulWidget {
  const PathEditorPage({super.key});

  @override
  State<PathEditorPage> createState() => _PathEditorPageState();
}

class _PathEditorPageState extends State<PathEditorPage> {
  List<PointNode> _currentPoints = [];
  int? _selectedPointIndex;
  bool _showConnections = false;

  @override
  void initState() {
    super.initState();
    // Create empty path when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      if (!appState.hasPath) {
        appState.createNewPath();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: const TopBar(),
          body: KeyboardListener(
            focusNode: FocusNode()..requestFocus(),
            onKeyEvent: (event) => _handleKeyPress(event, appState),
            child: Row(
              children: [
                // Left: Command list
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyles.defaultPadding),
                        color: AppStyles.primaryColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Commands',
                              style: AppStyles.subtitleStyle.copyWith(color: Colors.white),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () => _showAddCommandDialog(context, appState),
                              tooltip: 'Add Command',
                            ),
                          ],
                        ),
                      ),
                      const Expanded(child: CommandList()),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                // Center: Grid canvas
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Toolbar
                      Container(
                        padding: const EdgeInsets.all(AppStyles.smallPadding),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Points: ${_currentPoints.length}',
                              style: AppStyles.bodyStyle,
                            ),
                            const SizedBox(width: AppStyles.defaultPadding),
                            ElevatedButton.icon(
                              onPressed: _currentPoints.length >= 2
                                  ? () {
                                      setState(() {
                                        _showConnections = !_showConnections;
                                      });
                                    }
                                  : null,
                              icon: Icon(_showConnections ? Icons.link_off : Icons.link),
                              label: Text(_showConnections ? 'Hide Path' : 'Connect Points'),
                            ),
                            const SizedBox(width: AppStyles.smallPadding),
                            ElevatedButton.icon(
                              onPressed: _currentPoints.isNotEmpty
                                  ? () => _saveCurrentPath(context, appState)
                                  : null,
                              icon: const Icon(Icons.check),
                              label: const Text('Save to Commands'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppStyles.accentColor,
                              ),
                            ),
                            const Spacer(),
                            if (_currentPoints.isNotEmpty)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _currentPoints.clear();
                                    _selectedPointIndex = null;
                                    _showConnections = false;
                                  });
                                },
                                icon: const Icon(Icons.clear, color: AppStyles.errorColor),
                                label: const Text('Clear All'),
                              ),
                          ],
                        ),
                      ),
                      // Grid
                      Expanded(
                        child: GridCanvas(
                          robotProfile: appState.robotProfile,
                          points: _currentPoints,
                          selectedPointIndex: _selectedPointIndex,
                          showConnections: _showConnections,
                          onPointAdded: _addPoint,
                          onPointSelected: (index) {
                            setState(() {
                              _selectedPointIndex = index;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                // Right: Point properties
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyles.defaultPadding),
                        color: AppStyles.primaryColor,
                        child: Row(
                          children: [
                            Text(
                              'Point Properties',
                              style: AppStyles.subtitleStyle.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _selectedPointIndex != null &&
                                _selectedPointIndex! < _currentPoints.length
                            ? SingleChildScrollView(
                                key: ValueKey(_selectedPointIndex),
                                child: PointEditor(
                                  key: ValueKey('point_${_selectedPointIndex}_${_currentPoints[_selectedPointIndex!].x}_${_currentPoints[_selectedPointIndex!].y}'),
                                  point: _currentPoints[_selectedPointIndex!],
                                  onPointChanged: (updatedPoint) {
                                    setState(() {
                                      _currentPoints[_selectedPointIndex!] = updatedPoint;
                                    });
                                  },
                                  onDelete: () {
                                    setState(() {
                                      _currentPoints.removeAt(_selectedPointIndex!);
                                      _reindexPoints();
                                      _selectedPointIndex = null;
                                    });
                                  },
                                ),
                              )
                            : Center(
                                child: Text(
                                  'Select a point to edit',
                                  style: AppStyles.captionStyle,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleKeyPress(KeyEvent event, AppState appState) {
    if (event is KeyDownEvent) {
      // Undo/redo shortcuts
      if (event.logicalKey == LogicalKeyboardKey.keyZ &&
          HardwareKeyboard.instance.isControlPressed) {
        appState.undoRedoService.undo();
      } else if (event.logicalKey == LogicalKeyboardKey.keyY &&
          HardwareKeyboard.instance.isControlPressed) {
        appState.undoRedoService.redo();
      }
      // Delete selected point
      else if (event.logicalKey == LogicalKeyboardKey.delete ||
          event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_selectedPointIndex != null) {
          setState(() {
            _currentPoints.removeAt(_selectedPointIndex!);
            _reindexPoints();
            _selectedPointIndex = null;
          });
        }
      }
    }
  }

  void _addPoint(Offset position) {
    setState(() {
      final newPoint = PointNode(
        index: _currentPoints.length,
        x: position.dx,
        y: position.dy,
        angle: 0,
        time: _currentPoints.isEmpty ? 0 : _currentPoints.last.time + 1.0,
      );
      _currentPoints.add(newPoint);
      _selectedPointIndex = _currentPoints.length - 1;
    });
  }

  void _reindexPoints() {
    for (int i = 0; i < _currentPoints.length; i++) {
      _currentPoints[i] = _currentPoints[i].copyWith(index: i);
    }
  }

  void _saveCurrentPath(BuildContext context, AppState appState) {
    if (_currentPoints.isEmpty) return;

    // Create command with points in arguments
    final commandBlock = CommandBlock(
      index: appState.currentPath?.commands.length ?? 0,
      commands: ['PurePursuitFollowPath'],
      arguments: {
        'points': _currentPoints.map((p) => p.toJson()).toList(),
      },
    );

    appState.currentPath?.addCommand(commandBlock);
    
    setState(() {
      _currentPoints.clear();
      _selectedPointIndex = null;
      _showConnections = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Path saved to commands'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddCommandDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Command'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('Pure Pursuit Path'),
              subtitle: const Text('Create a new path with waypoints'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Click on the grid to add waypoints'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_split),
              title: const Text('Switch Command'),
              subtitle: const Text('Conditional branching'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Switch commands coming soon'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}