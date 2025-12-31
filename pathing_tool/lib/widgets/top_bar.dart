import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pathing_tool/state/app_state.dart';
import 'package:pathing_tool/services/file_service.dart';
import 'package:pathing_tool/ui/styles.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return AppBar(
          title: GestureDetector(
            onTap: () => _showEditNameDialog(context, appState),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appState.currentPath?.pathName ?? 'Autonomous Editor',
                  style: AppStyles.titleStyle.copyWith(color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 18, color: Colors.white70),
              ],
            ),
          ),
          backgroundColor: AppStyles.primaryColor,
          actions: [
            // Undo button
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: appState.undoRedoService.canUndo
                  ? () => appState.undoRedoService.undo()
                  : null,
              tooltip: appState.undoRedoService.undoDescription ?? 'Undo',
            ),
            // Redo button
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: appState.undoRedoService.canRedo
                  ? () => appState.undoRedoService.redo()
                  : null,
              tooltip: appState.undoRedoService.redoDescription ?? 'Redo',
            ),
            const VerticalDivider(color: Colors.white30),
            // Import button
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () => _importPath(context, appState),
              tooltip: 'Import Path',
            ),
            // Export button
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: appState.hasPath
                  ? () => _exportPath(context, appState)
                  : null,
              tooltip: 'Export Path',
            ),
            const SizedBox(width: AppStyles.smallPadding),
          ],
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, AppState appState) {
    if (appState.currentPath == null) return;

    final controller = TextEditingController(text: appState.currentPath!.pathName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Autonomous Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              appState.currentPath!.pathName = value.trim();
              appState.notifyListeners();
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                appState.currentPath!.pathName = controller.text.trim();
                appState.notifyListeners();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _importPath(BuildContext context, AppState appState) async {
    final pathData = await FileService.importPath();
    
    if (pathData != null) {
      appState.loadPath(pathData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded "${pathData.pathName}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to import path'),
            backgroundColor: AppStyles.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _exportPath(BuildContext context, AppState appState) async {
    if (appState.currentPath == null) return;

    final success = await FileService.exportPath(appState.currentPath!);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Path exported successfully' : 'Export cancelled'),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    }
  }
}