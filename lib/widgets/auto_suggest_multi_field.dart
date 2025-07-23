import 'package:flutter/material.dart';
import 'auto_suggest_field.dart';
import 'auto_suggest_multi_select.dart';

/// Configuration for a single field in AutoSuggestMultiField
class FieldConfig {
  final String fieldKey;
  final List<String> options;
  final dynamic initialValue; // Can be String? or List<String>
  final String hintText;
  final bool multiSelect; // Whether this field allows multiple selections

  const FieldConfig({
    required this.fieldKey,
    required this.options,
    this.initialValue,
    required this.hintText,
    this.multiSelect = false, // Default to single select
  });
}

/// A widget that displays multiple AutoSuggestField or AutoSuggestMultiSelect widgets
/// and manages their values as a map.
class AutoSuggestMultiField extends StatefulWidget {
  /// List of field configurations
  final List<FieldConfig> fields;

  /// Initial values for each field, keyed by fieldKey
  /// Values can be String? (for single select) or List<String> (for multi-select)
  final Map<String, dynamic> initialValues;

  /// Callback when any field value changes
  /// Values in the map can be String? (for single select) or List<String> (for multi-select)
  final ValueChanged<Map<String, dynamic>> onChanged;

  /// Spacing between fields
  final double fieldSpacing;

  const AutoSuggestMultiField({
    super.key,
    required this.fields,
    this.initialValues = const {},
    required this.onChanged,
    this.fieldSpacing = 16.0,
  });

  @override
  State<AutoSuggestMultiField> createState() => _AutoSuggestMultiFieldState();
}

class _AutoSuggestMultiFieldState extends State<AutoSuggestMultiField> {
  late Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();
    // Initialize values with provided initialValues
    _values = Map.from(widget.initialValues);

    // Ensure all fields have a value in the map (even if it's null or empty list)
    for (var field in widget.fields) {
      if (!_values.containsKey(field.fieldKey)) {
        if (field.multiSelect) {
          // For multi-select fields, initialize with empty list or provided list
          _values[field.fieldKey] =
              field.initialValue is List<String>
                  ? field.initialValue
                  : <String>[];
        } else {
          // For single-select fields, initialize with null or provided string
          _values[field.fieldKey] =
              field.initialValue is String ? field.initialValue : null;
        }
      }
    }
  }

  void _updateSingleValue(String fieldKey, String? value) {
    setState(() {
      _values[fieldKey] = value;
      widget.onChanged(_values);
    });
  }

  void _updateMultiValue(String fieldKey, List<String> values) {
    setState(() {
      _values[fieldKey] = values;
      widget.onChanged(_values);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          widget.fields.map((field) {
            return Padding(
              padding: EdgeInsets.only(bottom: widget.fieldSpacing),
              child:
                  field.multiSelect
                      ? AutoSuggestMultiSelect(
                        options: field.options,
                        initialValues:
                            _values[field.fieldKey] is List<String>
                                ? _values[field.fieldKey]
                                : <String>[],
                        hintText: field.hintText,
                        onChanged:
                            (values) =>
                                _updateMultiValue(field.fieldKey, values),
                      )
                      : AutoSuggestField(
                        options: field.options,
                        initialValue:
                            _values[field.fieldKey] is String
                                ? _values[field.fieldKey]
                                : null,
                        hintText: field.hintText,
                        onChanged:
                            (value) =>
                                _updateSingleValue(field.fieldKey, value),
                      ),
            );
          }).toList(),
    );
  }
}
