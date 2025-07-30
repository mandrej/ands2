import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../values/bloc/available_values_bloc.dart';
import '../find/cubit/find_cubit.dart';
import '../photo/bloc/photo_bloc.dart';
import 'auto_suggest_multi_field.dart';

class FindForm extends StatelessWidget {
  const FindForm({super.key});

  // Helper method to update a field in FindCubit
  void _updateField(
    FindCubit cubit,
    String fieldKey,
    dynamic value,
    dynamic Function(dynamic) transform,
  ) {
    final transformedValue = transform(value);
    cubit.findChange(fieldKey, transformedValue);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FindCubit, FindState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSuggestMultiField(
                fields: [
                  FieldConfig(
                    fieldKey: 'year',
                    hintText: 'by year',
                    options:
                        AvailableValuesBloc().state.year!.keys
                            .map((e) => e.toString())
                            .toList(),
                  ),
                  FieldConfig(
                    fieldKey: 'month',
                    hintText: 'by month',
                    options: AvailableValuesBloc().state.month!.keys.toList(),
                  ),
                  FieldConfig(
                    fieldKey: 'tags',
                    hintText: 'by tags',
                    options: AvailableValuesBloc().state.tags!.keys.toList(),
                    multiSelect: true, // Enable multi-select for tags
                  ),
                  FieldConfig(
                    fieldKey: 'model',
                    hintText: 'by camera model',
                    options: AvailableValuesBloc().state.model!.keys.toList(),
                  ),
                  FieldConfig(
                    fieldKey: 'lens',
                    hintText: 'by lens',
                    options: AvailableValuesBloc().state.lens!.keys.toList(),
                  ),
                  FieldConfig(
                    fieldKey: 'nick',
                    hintText: 'by photographer',
                    options: AvailableValuesBloc().state.nick!.keys.toList(),
                  ),
                ],
                initialValues: {
                  'year': state.find.year?.toString(),
                  'month':
                      AvailableValuesBloc().state.month!.entries
                          .firstWhere(
                            (entry) => entry.value == state.find.month,
                            orElse: () => const MapEntry('', 0),
                          )
                          .key,
                  'tags': state.find.tags ?? <String>[],
                  'model': state.find.model,
                  'lens': state.find.lens,
                  'nick': state.find.nick,
                },
                onChanged: (values) {
                  final findCubit = context.read<FindCubit>();

                  // Process each field and update FindCubit
                  _updateField(findCubit, 'year', values['year'], (value) {
                    return value != null && value.isNotEmpty
                        ? int.tryParse(value)
                        : null;
                  });

                  _updateField(findCubit, 'month', values['month'], (value) {
                    if (value != null && value.isNotEmpty) {
                      final availableValues = AvailableValuesBloc().state;
                      final monthMap = availableValues.month;
                      if (monthMap != null && monthMap.containsKey(value)) {
                        return monthMap[value];
                      }
                    }
                    return null;
                  });

                  // Handle tags specially since it's a list
                  final tagsValue = values['tags'];
                  findCubit.findChange('tags', tagsValue ?? <String>[]);

                  // Handle other string fields
                  _updateField(findCubit, 'model', values['model'], (value) {
                    return value != null && value.isNotEmpty ? value : null;
                  });

                  _updateField(findCubit, 'lens', values['lens'], (value) {
                    return value != null && value.isNotEmpty ? value : null;
                  });

                  _updateField(findCubit, 'nick', values['nick'], (value) {
                    return value != null && value.isNotEmpty ? value : null;
                  });

                  // Explicitly notify PhotoBloc about the change
                  final photoBloc = context.read<PhotoBloc>();
                  photoBloc.add(PhotoFetched(findState: findCubit.state));
                },
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}
