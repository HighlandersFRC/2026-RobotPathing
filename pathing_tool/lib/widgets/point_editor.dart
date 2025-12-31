import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pathing_tool/models/point_node.dart';
import 'package:pathing_tool/services/utils.dart';
import 'package:pathing_tool/ui/styles.dart';

class PointEditor extends StatefulWidget {
  final PointNode point;
  final Function(PointNode) onPointChanged;
  final VoidCallback? onDelete;

  const PointEditor({
    super.key,
    required this.point,
    required this.onPointChanged,
    this.onDelete,
  });

  @override
  State<PointEditor> createState() => _PointEditorState();
}

class _PointEditorState extends State<PointEditor> {
  late TextEditingController _xController;
  late TextEditingController _yController;
  late TextEditingController _angleController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _xController = TextEditingController(text: widget.point.x.toStringAsFixed(2));
    _yController = TextEditingController(text: widget.point.y.toStringAsFixed(2));
    _angleController = TextEditingController(
      text: GeometryUtils.radiansToDegrees(widget.point.angle).toStringAsFixed(1),
    );
    _timeController = TextEditingController(text: widget.point.time.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _angleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _updatePoint() {
    final x = double.tryParse(_xController.text) ?? widget.point.x;
    final y = double.tryParse(_yController.text) ?? widget.point.y;
    final angleDegrees = double.tryParse(_angleController.text) ?? 
        GeometryUtils.radiansToDegrees(widget.point.angle);
    final time = double.tryParse(_timeController.text) ?? widget.point.time;

    final updatedPoint = widget.point.copyWith(
      x: x,
      y: y,
      angle: GeometryUtils.degreesToRadians(angleDegrees),
      time: time,
    );

    widget.onPointChanged(updatedPoint);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppStyles.smallPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Point ${widget.point.index}',
                  style: AppStyles.subtitleStyle,
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppStyles.errorColor),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete Point',
                  ),
              ],
            ),
            const SizedBox(height: AppStyles.smallPadding),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _xController,
                    label: 'X (m)',
                  ),
                ),
                const SizedBox(width: AppStyles.smallPadding),
                Expanded(
                  child: _buildTextField(
                    controller: _yController,
                    label: 'Y (m)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.smallPadding),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _angleController,
                    label: 'Angle (°)',
                  ),
                ),
                const SizedBox(width: AppStyles.smallPadding),
                Expanded(
                  child: _buildTextField(
                    controller: _timeController,
                    label: 'Time (s)',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppStyles.smallPadding,
          vertical: AppStyles.smallPadding,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
      // Only update when user is done editing (loses focus or presses enter)
      onSubmitted: (_) => _updatePoint(),
      onEditingComplete: _updatePoint,
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
        _updatePoint();
      },
      style: AppStyles.bodyStyle,
    );
  }
}