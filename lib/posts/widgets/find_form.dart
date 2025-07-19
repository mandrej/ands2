import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/find/cubit/find_cubit.dart';
import 'package:flutter_infinite_list/photos/bloc/record_bloc.dart';

class FindForm extends StatefulWidget {
  const FindForm({super.key});

  @override
  State<FindForm> createState() => _FindFormState();
}

class _FindFormState extends State<FindForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController yearController;
  late final TextEditingController monthController;

  @override
  void initState() {
    super.initState();
    yearController = TextEditingController(
      text:
          context.read<FindCubit>().state.find.year != null
              ? context.read<FindCubit>().state.find.year.toString()
              : '',
    );
    monthController = TextEditingController(
      text:
          context.read<FindCubit>().state.find.month != null
              ? context.read<FindCubit>().state.find.month.toString()
              : '',
    );
  }

  @override
  void dispose() {
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<FindCubit, FindState>(
          builder: (context, state) {
            return Column(
              children: [
                TextFormField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Filter by year',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        yearController.clear();
                        context.read<RecordBloc>().add(RecordClear());
                        context.read<FindCubit>().findChange('year', null);
                      },
                    ),
                  ),
                  onSaved: (newValue) {
                    setState(() {
                      context.read<FindCubit>().findChange(
                        'year',
                        int.tryParse(newValue!),
                      );
                    });
                  },
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter year';
                  //   } else if (value.length != 4) {
                  //     return 'Please enter 4 digits';
                  //   }
                  //   return null;
                  // },
                ),
                TextFormField(
                  controller: monthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Filter by month',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        monthController.clear();
                        context.read<RecordBloc>().add(RecordClear());
                        context.read<FindCubit>().findChange('month', null);
                      },
                    ),
                  ),
                  onSaved: (newValue) {
                    setState(() {
                      context.read<FindCubit>().findChange(
                        'month',
                        int.tryParse(newValue!),
                      );
                    });
                  },
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter month';
                  //   } else if (int.tryParse(value)! < 1 ||
                  //       int.tryParse(value)! > 12) {
                  //     return 'Please enter valid month (1-12)';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState?.save();
                      context.read<RecordBloc>().add(RecordClear());
                      // context.read<FindCubit>().findChange(
                      //   'year',
                      //   int.tryParse(yearController.text),
                      // );
                      // context.read<FindCubit>().findChange(
                      //   'month',
                      //   int.tryParse(monthController.text),
                      // );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
