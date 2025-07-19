import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_infinite_list/find/models/find.dart';
import 'package:equatable/equatable.dart';

part 'find_state.dart';

class FindCubit extends HydratedCubit<FindState> {
  FindCubit() : super(FindInitial());

  void findChange(String key, dynamic value) {
    final currentFind =
        state is FindUpdated
            ? Find.fromJson((state as FindUpdated).data)
            : const Find();
    final updatedFind = currentFind.copyWithField(key, value);

    final cleanedJson =
        updatedFind.toJson()..removeWhere(
          (k, v) =>
              v == null ||
              (v is String && v.isEmpty) ||
              (v is List && v.isEmpty) ||
              (v is int && v == 0),
        );

    // print(cleanedJson.toString());
    emit(FindUpdated(data: cleanedJson));
  }

  @override
  FindState? fromJson(Map<String, dynamic> json) {
    try {
      final cleaned = json..removeWhere((k, v) => v == null);
      return FindUpdated(data: cleaned);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(FindState state) {
    if (state is FindUpdated) {
      return state.data;
    }
    return null;
  }
}
