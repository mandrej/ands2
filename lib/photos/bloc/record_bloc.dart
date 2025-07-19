import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/find/cubit/find_cubit.dart';
import 'package:flutter_infinite_list/photos/models/record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_transform/stream_transform.dart';

part 'record_event.dart';
part 'record_state.dart';

const _postLimit = 10;
const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final FindCubit _findCubit;

  RecordBloc(this._findCubit) : super(const RecordState()) {
    _findCubit.stream.listen((state) {
      add(RecordFetched(findState: state));
    });

    on<RecordFetched>(
      _onFetched,
      transformer: throttleDroppable(throttleDuration),
    );

    on<RecordClear>(_onClear, transformer: throttleDroppable(throttleDuration));
  }

  void _onClear(RecordClear event, Emitter<RecordState> emit) {
    emit(state.copyWith(records: [], hasReachedMax: false));
  }

  Future<void> _onFetched(
    RecordFetched event,
    Emitter<RecordState> emit,
  ) async {
    final findState = event.findState;

    if (state.hasReachedMax) return;

    var records = <Record>[];
    try {
      if (state.records.isEmpty) {
        records = await _fetchRecords(findState: findState);
      } else {
        records = await _fetchRecords(
          fromFilename: state.records.last.filename,
          findState: findState,
        );
      }
      if (records.isEmpty) {
        return emit(state.copyWith(hasReachedMax: true));
      }
      // if (findState is FindUpdated || findState is FindInitial) {
      //   state.records.clear();
      //   // add(RecordClear());
      // }

      emit(
        state.copyWith(
          status: RecordStatus.success,
          records: [...state.records, ...records],
        ),
      );
    } catch (_) {
      // print('error fetching records: $e $s');
      emit(state.copyWith(status: RecordStatus.failure));
    }
  }

  Future<List<Record>> _fetchRecords({
    String? fromFilename,
    FindState? findState,
  }) async {
    final db = FirebaseFirestore.instance;
    // print('--findState: ${findState.runtimeType} ${findState!.find}');

    Query<Map<String, dynamic>> query = db.collection('Photo');

    try {
      query = query.orderBy('date', descending: true);

      if (findState?.find.year != null) {
        query = query.where('year', isEqualTo: findState?.find.year);
      }
      if (findState?.find.month != null) {
        query = query.where('month', isEqualTo: findState?.find.month);
      }

      if (fromFilename != null) {
        DocumentSnapshot from =
            await db.collection('Photo').doc(fromFilename).get();
        query = query.startAfterDocument(from);
      }
      query = query.limit(_postLimit);
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => Record.fromMap(doc.data()))
          .toList();
    } catch (error) {
      throw Exception('error fetching records: $error');
    }
  }
}
