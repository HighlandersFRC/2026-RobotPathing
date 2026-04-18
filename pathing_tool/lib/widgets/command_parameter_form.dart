import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pathing_tool/models/command_definition.dart';
import 'package:pathing_tool/models/parameter_definition.dart';
import 'package:pathing_tool/ui/styles.dart';

class CommandParameterForm extends StatefulWidget {
  final CommandDefinition commandDef;
  final Map<String, dynamic> initialValues;
  final Function(Map<String, dynamic>) onSubmit;

  const CommandParameterForm({
    super.key,
    required this.commandDef,
    required this.initialValues,
    required this.onSubmit,
  });

  @override
  State<CommandParameterForm> createState() => _CommandParameterFormState();
}

class _CommandParameterFormState extends State<CommandParameterForm> {
  late Map<String, dynamic> _values;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _values = Map.from(widget.initialValues);

    // Initialize with defaults if not provided
    for (var param in widget.commandDef.nonPathParameters) {
      if (!_values.containsKey(param.name) && param.defaultValue != null) {
        _values[param.name] = param.defaultValue;
      }
      
      // Create controllers for text fields
      if (param.type == ParameterType.string ||
          param.type == ParameterType.integer ||
          param.type == ParameterType.double) {
        _controllers[param.name] = TextEditingController(
          text: _values[param.name]?.toString() ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nonPathParams = widget.commandDef.nonPathParameters;

    if (nonPathParams.isEmpty) {
      // No parameters to configure
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'This command has no additional parameters',
            style: AppStyles.bodyStyle,
          ),
          const SizedBox(height: AppStyles.defaultPadding),
          ElevatedButton(
            onPressed: () => widget.onSubmit({}),
            child: const Text('Add Command'),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.commandDef.displayName,
          style: AppStyles.subtitleStyle,
        ),
        if (widget.commandDef.description != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.commandDef.description!,
            style: AppStyles.captionStyle,
          ),
        ],
        const SizedBox(height: AppStyles.defaultPadding),
        ...nonPathParams.map((param) => _buildParameterField(param)),
        const SizedBox(height: AppStyles.defaultPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add Command'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParameterField(ParameterDefinition param) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.smallPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${param.name}${param.required ? ' *' : ''}',
            style: AppStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildInputWidget(param),
        ],
      ),
    );
  }

  Widget _buildInputWidget(ParameterDefinition param) {
    switch (param.type) {
      case ParameterType.string:
        return TextField(
          controller: _controllers[param.name],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: param.defaultValue?.toString(),
          ),
        );

      case ParameterType.integer:
        return TextField(
          controller: _controllers[param.name],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: param.defaultValue?.toString(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );

      case ParameterType.double:
        return TextField(
          controller: _controllers[param.name],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: param.defaultValue?.toString(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
        );

      case ParameterType.boolean:
        return CheckboxListTile(
          value: _values[param.name] as bool? ?? param.defaultValue ?? false,
          onChanged: (value) {
            setState(() {
              _values[param.name] = value ?? false;
            });
          },
          title: Text(param.name),
        );

      case ParameterType.enumType:
        return DropdownButtonFormField<String>(
          value: _values[param.name] as String?,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: param.enumOptions!
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _values[param.name] = value;
            });
          },
        );

      case ParameterType.pathPoints:
        return const Text('Path points configured on canvas');
    }
  }

  void _submit() {
    final values = <String, dynamic>{};

    for (var param in widget.commandDef.nonPathParameters) {
      if (param.type == ParameterType.string ||
          param.type == ParameterType.integer ||
          param.type == ParameterType.double) {
        final text = _controllers[param.name]!.text;
        if (text.isEmpty) {
          if (param.required) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${param.name} is required')),
            );
            return;
          } else if (param.defaultValue != null) {
            values[param.name] = param.defaultValue;
          }
        } else {
          if (param.type == ParameterType.integer) {
            values[param.name] = int.parse(text);
          } else if (param.type == ParameterType.double) {
            values[param.name] = double.parse(text);
          } else {
            values[param.name] = text;
          }
        }
      } else {
        values[param.name] = _values[param.name];
      }
    }

    widget.onSubmit(values);
    Navigator.of(context).pop();
  }
}