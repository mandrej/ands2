import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_infinite_list/values/models/values.dart';
import 'package:flutter_infinite_list/helpers/common.dart';

part 'available_values_event.dart';
part 'available_values_state.dart';

enum AvailableValuesStatus { initial, loading, success, error }

const months = {
  'January': 1,
  'February': 2,
  'March': 3,
  'April': 4,
  'May': 5,
  'June': 6,
  'July': 7,
  'August': 8,
  'September': 9,
  'October': 10,
  'November': 11,
  'December': 12,
};

Future<Values?> getValues(String kind) async {
  final db = FirebaseFirestore.instance;
  var result = <String, Map<String, int>>{};

  try {
    final querySnapshot = await db.collection(kind).get();
    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        var d = doc.data();
        if (!result.containsKey(d['field'])) {
          // start field
          result[d['field']] = {d['value']: d['count']};
        } else {
          result[d['field']]!.addAll({d['value']: d['count']});
        }
      }
      // Only build 'nick' and 'month' once after all docs are processed
      if (result['email'] != null) {
        result['nick'] = {};
        result['email']?.forEach((key, value) {
          result['nick']![nickEmail(key)] = value;
        });
      }
      result['month'] = months;
    }
  } catch (e) {
    print('Error completing: $e');
  }
  if (result.isNotEmpty) {
    return Values(
      year: result['year'] ?? {},
      month: result['month'] ?? {},
      tags: result['tags'] ?? {},
      email: result['email'] ?? {},
      nick: result['nick'] ?? {},
      model: result['model'] ?? {},
      lens: result['lens'] ?? {},
    );
  } else {
    return null;
  }
}

class AvailableValuesBloc
    extends HydratedBloc<AvailableValuesEvent, AvailableValuesState> {
  AvailableValuesBloc()
    : super(
        AvailableValuesState(
          status: AvailableValuesStatus.initial,
          loading: false,
        ),
      ) {
    on<FetchAvailableValues>(_onFetchAvailableValues);
  }

  Future<void> _onFetchAvailableValues(
    FetchAvailableValues event,
    Emitter<AvailableValuesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AvailableValuesStatus.loading,
        loading: true,
        error: null,
      ),
    );
    try {
      final values = await getValues('Counter');
      emit(
        state.copyWith(
          values: values,
          status: AvailableValuesStatus.success,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AvailableValuesStatus.error,
          loading: false,
          error: e.toString(),
        ),
      );
    }
  }

  @override
  AvailableValuesState? fromJson(Map<String, dynamic> json) {
    return AvailableValuesState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(AvailableValuesState state) {
    return state.toMap();
  }
}
