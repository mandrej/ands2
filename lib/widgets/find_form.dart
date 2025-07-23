import 'package:flutter/material.dart';
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
                },
                onChanged: (values) {
                  context.read<PhotoBloc>().add(PhotoClear());

                  if (values.containsKey('year') && values['year'] != null) {
                    context.read<FindCubit>().findChange(
                      'year',
                      int.tryParse(values['year']!),
                    );
                  }
                  if (values.containsKey('month') && values['month'] != null) {
                    context.read<FindCubit>().findChange(
                      'month',
                      AvailableValuesBloc().state.month![values['month']],
                    );
                  }
                  // Handle tags change (multi-select)
                  if (values.containsKey('tags')) {
                    context.read<FindCubit>().findChange(
                      'tags',
                      values['tags'],
                    );
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
