import 'package:flutter/material.dart';
import 'package:pathing_tool/models/command_block.dart';
import 'package:pathing_tool/services/geometry_utils.dart';
import 'package:pathing_tool/ui/styles.dart';

class CommandBlockWidget extends StatelessWidget {
  final CommandBlock commandBlock;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CommandBlockWidget({
    super.key,
    required this.commandBlock,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: onTap,
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
                          'Command ${commandBlock.index}',
                          style: AppStyles.subtitleStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          commandBlock.commands.join(', '),
                          style: AppStyles.bodyStyle.copyWith(
                            color: AppStyles.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppStyles.errorColor,
                      onPressed: onDelete,
                      tooltip: 'Delete Command',
                    ),
                ],
              ),
              const SizedBox(height: AppStyles.smallPadding),
              _buildArgumentsInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArgumentsInfo() {
    // Show point info if this is a path command
    final points = CommandUtils.getPointsFromCommand(commandBlock);
    
    if (points != null && points.isNotEmpty) {
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
              'Path Points: ${points.length}',
              style: AppStyles.captionStyle,
            ),
            const SizedBox(height: 4),
            Text(
              'Start: (${points.first.x.toStringAsFixed(1)}, ${points.first.y.toStringAsFixed(1)})',
              style: AppStyles.captionStyle,
            ),
            if (points.length > 1)
              Text(
                'End: (${points.last.x.toStringAsFixed(1)}, ${points.last.y.toStringAsFixed(1)})',
                style: AppStyles.captionStyle,
              ),
          ],
        ),
      );
    }

    // Show generic arguments for non-path commands
    if (commandBlock.arguments.isNotEmpty) {
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
              'Arguments:',
              style: AppStyles.captionStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...commandBlock.arguments.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: AppStyles.captionStyle,
              ),
            )),
          ],
        ),
      );
    }

    return Text(
      'No arguments',
      style: AppStyles.captionStyle,
    );
  }
}