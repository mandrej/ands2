import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../find/cubit/find_cubit.dart';
import '../models/photo.dart';

part 'photo_event.dart';
part 'photo_state.dart';

const _postLimit = 10;
const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  final FindCubit _findCubit;

  PhotoBloc(this._findCubit) : super(PhotoState(records: <Photo>[])) {
    _findCubit.stream.listen((state) {
      add(PhotoFetched(findState: state));
    });

    on<PhotoFetched>(
      _onFetched,
      transformer: throttleDroppable(throttleDuration),
    );

    on<PhotoClear>(_onClear, transformer: throttleDroppable(throttleDuration));
  }

  void _onClear(PhotoClear event, Emitter<PhotoState> emit) {
    emit(state.copyWith(records: <Photo>[], hasReachedMax: false));
  }

  Future<void> _onFetched(PhotoFetched event, Emitter<PhotoState> emit) async {
    final findState = event.findState;

    if (state.hasReachedMax) return;
    var records = <Photo>[];
    try {
      if (state.records.isEmpty) {
        records = await _fetchPhotos(findState: findState);
      } else {
        records = await _fetchPhotos(
          fromFilename: (state.records.last).filename,
          findState: findState,
        );
      }
      if (records.isEmpty) {
        return emit(state.copyWith(hasReachedMax: true));
      }

      emit(
        state.copyWith(
          status: PhotoStatus.success,
          records: [...state.records, ...records],
        ),
      );
    } catch (_) {
      // print('error fetching records: $e $s');
      emit(state.copyWith(status: PhotoStatus.failure));
    }
  }

  Future<List<Photo>> _fetchPhotos({
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
          .map((doc) => Photo.fromMap(doc.data()))
          .toList();
    } catch (error) {
      throw Exception('error fetching records: $error');
    }
  }
}
