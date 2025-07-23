import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../values/bloc/available_values_bloc.dart';
import '../find/cubit/find_cubit.dart';
import '../photo/bloc/photo_bloc.dart';
import '../widgets/auto_suggest_multi_field.dart';

class AutoSuggestMultiFieldExample extends StatefulWidget {
  const AutoSuggestMultiFieldExample({super.key});

  @override
  State<AutoSuggestMultiFieldExample> createState() =>
      _AutoSuggestMultiFieldExampleState();
}

class _AutoSuggestMultiFieldExampleState
    extends State<AutoSuggestMultiFieldExample> {
  // Store the current values
  Map<String, dynamic> _currentValues = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AutoSuggestMultiField Example')),
      body: BlocProvider(
        create: (context) => FindCubit(),
        child: BlocBuilder<FindCubit, FindState>(
          builder: (context, state) {
            // Get available values from the bloc
            final availableValues = AvailableValuesBloc().state;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Create a comprehensive example with multiple fields
                  AutoSuggestMultiField(
                    fields: [
                      FieldConfig(
                        fieldKey: 'year',
                        hintText: 'Filter by year',
                        initialValue: state.find.year?.toString(),
                        options:
                            availableValues.year!.keys
                                .map((e) => e.toString())
                                .toList(),
                      ),
                      FieldConfig(
                        fieldKey: 'month',
                        hintText: 'Filter by month',
                        initialValue:
                            availableValues.month!.entries
                                .firstWhere(
                                  (entry) => entry.value == state.find.month,
                                  orElse: () => const MapEntry('', 0),
                                )
                                .key,
                        options: availableValues.month!.keys.toList(),
                      ),
                      FieldConfig(
                        fieldKey: 'model',
                        hintText: 'Filter by camera model',
                        initialValue: state.find.model,
                        options: availableValues.model!.keys.toList(),
                      ),
                      FieldConfig(
                        fieldKey: 'lens',
                        hintText: 'Filter by lens',
                        initialValue: state.find.lens,
                        options: availableValues.lens!.keys.toList(),
                      ),
                      FieldConfig(
                        fieldKey: 'nick',
                        hintText: 'Filter by photographer',
                        initialValue: state.find.nick,
                        options: availableValues.nick!.keys.toList(),
                      ),
                      // Example of a multi-select field for tags
                      FieldConfig(
                        fieldKey: 'tags',
                        hintText: 'Filter by tags',
                        initialValue: state.find.tags ?? <String>[],
                        options: availableValues.tags!.keys.toList(),
                        multiSelect: true, // Enable multi-select for this field
                      ),
                    ],
                    initialValues: {
                      'year': state.find.year?.toString(),
                      'month':
                          availableValues.month!.entries
                              .firstWhere(
                                (entry) => entry.value == state.find.month,
                                orElse: () => const MapEntry('', 0),
                              )
                              .key,
                      'model': state.find.model,
                      'lens': state.find.lens,
                      'nick': state.find.nick,
                      'tags': state.find.tags ?? <String>[],
                    },
                    onChanged: (values) {
                      // Store the current values for display
                      setState(() {
                        _currentValues = values;
                      });

                      // Clear photos when filters change
                      context.read<PhotoBloc>().add(PhotoClear());

                      // Update the find state with new values
                      if (values.containsKey('year') &&
                          values['year'] != null) {
                        context.read<FindCubit>().findChange(
                          'year',
                          int.tryParse(values['year']!),
                        );
                      }

                      if (values.containsKey('month') &&
                          values['month'] != null) {
                        final monthValue =
                            availableValues.month![values['month']];
                        context.read<FindCubit>().findChange(
                          'month',
                          monthValue,
                        );
                      }

                      if (values.containsKey('model')) {
                        context.read<FindCubit>().findChange(
                          'model',
                          values['model'],
                        );
                      }

                      if (values.containsKey('lens')) {
                        context.read<FindCubit>().findChange(
                          'lens',
                          values['lens'],
                        );
                      }

                      if (values.containsKey('nick')) {
                        context.read<FindCubit>().findChange(
                          'nick',
                          values['nick'],
                        );
                      }

                      // Handle tags (multi-select field)
                      if (values.containsKey('tags')) {
                        context.read<FindCubit>().findChange(
                          'tags',
                          values['tags'],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Display the current values
                  const Text(
                    'Current Filter Values:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Show the current values in a card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Year: ${_currentValues['year'] ?? 'Not selected'}',
                          ),
                          Text(
                            'Month: ${_currentValues['month'] ?? 'Not selected'}',
                          ),
                          Text(
                            'Camera Model: ${_currentValues['model'] ?? 'Not selected'}',
                          ),
                          Text(
                            'Lens: ${_currentValues['lens'] ?? 'Not selected'}',
                          ),
                          Text(
                            'Photographer: ${_currentValues['nick'] ?? 'Not selected'}',
                          ),
                          // Display tags as a comma-separated list
                          Text(
                            'Tags: ${_currentValues['tags'] is List<String> && (_currentValues['tags'] as List<String>).isNotEmpty ? (_currentValues['tags'] as List<String>).join(', ') : 'Not selected'}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Add a button to clear all filters
                  ElevatedButton(
                    onPressed: () {
                      // Clear all filters
                      setState(() {
                        _currentValues = {};
                      });

                      // Clear the find state
                      context.read<FindCubit>().findChange('year', null);
                      context.read<FindCubit>().findChange('month', null);
                      context.read<FindCubit>().findChange('model', null);
                      context.read<FindCubit>().findChange('lens', null);
                      context.read<FindCubit>().findChange('nick', null);
                      context.read<FindCubit>().findChange('tags', null);

                      // Clear photos
                      context.read<PhotoBloc>().add(PhotoClear());
                    },
                    child: const Text('Clear All Filters'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
