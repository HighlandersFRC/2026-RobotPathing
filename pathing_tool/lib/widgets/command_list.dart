import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/command_block.dart';
import '../models/switch_block.dart';
import '../state/app_state.dart';
import '../ui/styles.dart';
import 'command_block_widget.dart';

class CommandList extends StatelessWidget {
  const CommandList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final path = appState.currentPath;

        if (path == null || path.commands.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.list_alt,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: AppStyles.defaultPadding),
                Text(
                  'No commands yet',
                  style: AppStyles.subtitleStyle.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: AppStyles.smallPadding),
                Text(
                  'Press + to add a command',
                  style: AppStyles.captionStyle,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppStyles.smallPadding),
          itemCount: path.commands.length,
          itemBuilder: (context, index) {
            final command = path.commands[index];
            final isSelected = appState.selectedCommandIndex == index;

            if (command is CommandBlock) {
              return CommandBlockWidget(
                commandBlock: command,
                isSelected: isSelected,
                onTap: () => appState.selectCommand(index),
                onDelete: () => _deleteCommand(context, appState, index),
              );
            } else if (command is SwitchBlock) {
              return _buildSwitchWidget(context, appState, command, index, isSelected);
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildSwitchWidget(
    BuildContext context,
    AppState appState,
    SwitchBlock switchBlock,
    int index,
    bool isSelected,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppStyles.defaultPadding,
        vertical: AppStyles.smallPadding,
      ),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? AppStyles.accentColor.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.defaultBorderRadius,
        side: BorderSide(
          color: isSelected ? AppStyles.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => appState.selectCommand(index),
        borderRadius: AppStyles.defaultBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Switch ${switchBlock.index}',
                          style: AppStyles.subtitleStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Condition: ${switchBlock.condition}',
                          style: AppStyles.bodyStyle.copyWith(
                            color: AppStyles.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppStyles.errorColor,
                    onPressed: () => _deleteCommand(context, appState, index),
                    tooltip: 'Delete Switch',
                  ),
                ],
              ),
              const SizedBox(height: AppStyles.smallPadding),
              _buildBranchInfo('On True', switchBlock.onTrue),
              const SizedBox(height: AppStyles.smallPadding),
              _buildBranchInfo('On False', switchBlock.onFalse),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchInfo(String label, List<CommandBlock> commands) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.smallPadding),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: AppStyles.defaultBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${commands.length} command(s)',
            style: AppStyles.captionStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          if (commands.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...commands.map((cmd) => Padding(
                  padding: const EdgeInsets.only(left: AppStyles.smallPadding, top: 2),
                  child: Text(
                    '• ${cmd.commands.join(', ')}',
                    style: AppStyles.captionStyle,
                  ),
                )),
          ],
        ],
      ),
    );
  }

  void _deleteCommand(BuildContext context, AppState appState, int index) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Command'),
        content: const Text('Are you sure you want to delete this command?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.currentPath?.removeCommand(index);
              appState.selectCommand(null);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppStyles.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}