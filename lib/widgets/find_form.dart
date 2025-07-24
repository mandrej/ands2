import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../values/bloc/available_values_bloc.dart';
import '../find/cubit/find_cubit.dart';
import '../photo/bloc/photo_bloc.dart';
import 'auto_suggest_multi_field.dart';

class FindForm extends StatelessWidget {
  const FindForm({super.key});

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
                    initialValue: state.find.tags ?? <String>[],
                    options: AvailableValuesBloc().state.tags!.keys.toList(),
                    multiSelect: true, // Enable multi-select for tags
                  ),
                  FieldConfig(
                    fieldKey: 'model',
                    hintText: 'by camera model',
                    initialValue:
                        state.find.model != null
                            ? [state.find.model!]
                            : <String>[],
                    options: AvailableValuesBloc().state.model!.keys.toList(),
                  ),
                  FieldConfig(
                    fieldKey: 'lens',
                    hintText: 'by lens',
                    initialValue:
                        state.find.lens != null
                            ? [state.find.lens!]
                            : <String>[],
                    options: AvailableValuesBloc().state.lens!.keys.toList(),
                  ),
                  FieldConfig(
                    fieldKey: 'nick',
                    hintText: 'by photographer',
                    initialValue:
                        state.find.nick != null
                            ? [state.find.nick!]
                            : <String>[],
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
                  context.read<PhotoBloc>().add(PhotoClear());
                  final findCubit = context.read<FindCubit>();

                  final yearValue = values['year'];
                  if (yearValue != null && yearValue.isNotEmpty) {
                    final parsedYear = int.tryParse(yearValue);
                    if (parsedYear == null) {
                      debugPrint('Warning: Invalid year format: $yearValue');
                    }
                    findCubit.findChange('year', parsedYear);
                  } else {
                    findCubit.findChange('year', null);
                  }

                  final monthValue = values['month'];
                  if (monthValue != null && monthValue.isNotEmpty) {
                    final availableValues = AvailableValuesBloc().state;
                    final monthMap = availableValues.month;

                    if (monthMap != null && monthMap.containsKey(monthValue)) {
                      findCubit.findChange('month', monthMap[monthValue]);
                    } else {
                      debugPrint('Warning: Invalid month value: $monthValue');
                      findCubit.findChange('month', null);
                    }
                  } else {
                    findCubit.findChange('month', null);
                  }

                  // Handle tags change (multi-select)
                  final tagsValue = values['tags'];
                  if (tagsValue.isNotEmpty) {
                    findCubit.findChange('tags', tagsValue);
                  } else {
                    findCubit.findChange('tags', null);
                  }
                  // For tags, we can directly pass the value (even empty list)
                  // as the Find model handles List<String>? properly

                  // Handle model field (camera model)
                  final modelValue = values['model'];
                  if (modelValue != null && modelValue.isNotEmpty) {
                    findCubit.findChange('model', modelValue);
                  } else {
                    findCubit.findChange('model', null);
                  }

                  // Handle lens field
                  final lensValue = values['lens'];
                  if (lensValue != null && lensValue.isNotEmpty) {
                    findCubit.findChange('lens', lensValue);
                  } else {
                    findCubit.findChange('lens', null);
                  }

                  // Handle nick field (photographer)
                  final nickValue = values['nick'];
                  if (nickValue != null && nickValue.isNotEmpty) {
                    findCubit.findChange('nick', nickValue);
                  } else {
                    findCubit.findChange('nick', null);
                  }
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
