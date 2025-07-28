import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../find/cubit/find_cubit.dart';
import '../../find/models/find.dart';
import '../../helpers/common.dart';
import '../models/photo.dart';

part 'photo_event.dart';
part 'photo_state.dart';

const _postLimit = 10;
const throttleDuration = Duration(milliseconds: 100);

final CollectionReference photosRef = FirebaseFirestore.instance.collection(
  'Photo',
);
final storageRef = FirebaseStorage.instance.ref();

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  PhotoBloc() : super(PhotoState(records: <Photo>[])) {
    on<PhotoFetched>(
      _onFetched,
      transformer: throttleDroppable(throttleDuration),
    );

    on<PhotoClear>(_onClear, transformer: throttleDroppable(throttleDuration));

    on<PhotoDelete>(
      _onPhotoDelete,
      transformer: throttleDroppable(throttleDuration),
    );

    on<PhotoAdd>(_onPhotoAdd, transformer: throttleDroppable(throttleDuration));

    on<PhotoUpdate>(
      _onPhotoUpdate,
      transformer: throttleDroppable(throttleDuration),
    );

    on<PhotoPublish>(
      _onPhotoPublish,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  void _onClear(PhotoClear event, Emitter<PhotoState> emit) {
    emit(state.copyWith(records: <Photo>[]));
  }

  Future<void> _onFetched(PhotoFetched event, Emitter<PhotoState> emit) async {
    final findState = event.findState;
    final fromFilename = event.fromFilename;

    // Check if filter has changed by comparing with the stored findState
    bool filterChanged = fromFilename == null;

    if (filterChanged) {
      // Clear records when filter changes
      emit(
        state.copyWith(
          records: <Photo>[],
          status: PhotoStatus.initial,
          findState: findState,
        ),
      );
    }

    var records = <Photo>[];
    try {
      if (filterChanged || state.records.isEmpty) {
        // Fetch from the beginning when filter changes or no records exist
        records = await _fetchPhotos(findState: findState);
      } else {
        // Continue pagination for the same filter
        records = await _fetchPhotos(
          fromFilename: fromFilename,
          // state.records.isNotEmpty ? state.records.last.filename : null,
          findState: findState,
        );
      }

      emit(
        state.copyWith(
          status: PhotoStatus.success,
          records: filterChanged ? records : [...state.records, ...records],
          findState: findState,
        ),
      );
    } catch (e) {
      print('error fetching records: $e');
      emit(state.copyWith(status: PhotoStatus.failure));
    }
  }

  Future<List<Photo>> _fetchPhotos({
    String? fromFilename,
    FindState? findState,
  }) async {
    final Find? find = findState?.find;

    try {
      Query<Object?> query = photosRef.orderBy('date', descending: true);

      if (find!.year != null) {
        query = query.where('year', isEqualTo: find.year);
      }
      if (find.month != null) {
        query = query.where('month', isEqualTo: find.month);
      }
      if (find.tags != null && find.tags!.isNotEmpty) {
        query = query.where('tags', arrayContainsAny: find.tags);
      }
      if (find.model != null) {
        query = query.where('model', isEqualTo: find.model);
      }
      if (find.lens != null) {
        query = query.where('lens', isEqualTo: find.lens);
      }
      if (find.nick != null) {
        query = query.where('nick', isEqualTo: find.nick);
      }

      if (fromFilename != null) {
        DocumentSnapshot from = await photosRef.doc(fromFilename).get();
        query = query.startAfterDocument(from);
      }
      query = query.limit(_postLimit);
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => Photo.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw Exception('error fetching records: $error');
    }
  }

  Future<void> _onPhotoDelete(
    PhotoDelete event,
    Emitter<PhotoState> emit,
  ) async {
    final docRef = photosRef.doc(event.filename);
    final imageRef = storageRef.child(event.filename);
    final thumbRef = storageRef.child(thumbFileName(event.filename));
    try {
      // Delete all resources in parallel for better performance
      // If any deletion fails, the entire operation will fail
      await Future.wait([
        docRef.delete(),
        imageRef.delete(),
        thumbRef.delete(),
      ]);
      // Remove the deleted photo from the state
      final updatedRecords =
          state.records
              .where((photo) => photo.filename != event.filename)
              .toList();
      emit(state.copyWith(records: updatedRecords));
    } catch (e) {
      print('error deleting record: $e');
      emit(state.copyWith(status: PhotoStatus.failure));
    }
  }

  Future<void> _onPhotoAdd(PhotoAdd event, Emitter<PhotoState> emit) async {
    final docRef = photosRef.doc(event.photo.filename);
    try {
      // Add the photo document to Firestore
      await docRef.set(event.photo.toMap());

      // Add the new photo to the beginning of the records list
      final updatedRecords = [event.photo, ...state.records];
      emit(state.copyWith(records: updatedRecords));
    } catch (e) {
      print('error adding record: $e');
      emit(state.copyWith(status: PhotoStatus.failure));
    }
  }

  Future<void> _onPhotoUpdate(
    PhotoUpdate event,
    Emitter<PhotoState> emit,
  ) async {
    final docRef = photosRef.doc(event.photo.filename);
    try {
      // Update the photo document in Firestore
      await docRef.update(event.photo.toMap());

      // Update the photo in the records list
      final updatedRecords =
          state.records.map((photo) {
            return photo.filename == event.photo.filename ? event.photo : photo;
          }).toList();
      emit(state.copyWith(records: updatedRecords));
    } catch (e) {
      print('error updating record: $e');
      emit(state.copyWith(status: PhotoStatus.failure));
    }
  }

  Future<void> _onPhotoPublish(
    PhotoPublish event,
    Emitter<PhotoState> emit,
  ) async {
    final docRef = photosRef.doc(event.photo.filename);
    try {
      // Update the published status in Firestore
      await docRef.update({'published': event.isPublished});

      // Update the photo in the records list
      final updatedRecords =
          state.records.map((photo) {
            if (photo.filename == event.photo.filename) {
              return photo.copyWith(published: event.isPublished);
            }
            return photo;
          }).toList();
      emit(state.copyWith(records: updatedRecords));
    } catch (e) {
      print('error updating publish status: $e');
      emit(state.copyWith(status: PhotoStatus.failure));
    }
  }
}
