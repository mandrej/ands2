import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_infinite_list/photo/models/photo.dart';

part 'first_photo_state.dart';

Future<Photo?> getRecord(String kind, bool descending) {
  final db = FirebaseFirestore.instance;
  return db
      .collection(kind)
      .orderBy('date', descending: descending)
      .limit(1)
      .get()
      .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data();
          return Photo.fromMap(data);
        }
        return null;
      })
      .catchError((e) {
        print('Error completing: $e');
        return null;
      });
}

class FirstRecordCubit extends Cubit<FirstRecordState> {
  FirstRecordCubit() : super(FirstRecordInitial());

  Future<void> fetchFirstRecord() async {
    emit(FirstRecordLoading());
    try {
      final photo = await getRecord('Photo', false);
      if (photo != null) {
        emit(FirstRecordLoaded(photo));
      } else {
        emit(FirstRecordEmpty());
      }
    } catch (e) {
      emit(FirstRecordError(e.toString()));
    }
  }
}

@override
FirstRecordState fromJson(Map<String, dynamic> json) {
  try {
    return FirstRecordLoaded.fromMap(json);
  } catch (_) {
    return FirstRecordInitial();
  }
}

@override
Map<String, dynamic>? toJson(FirstRecordState state) {
  if (state is FirstRecordLoaded) {
    return state.toMap();
  }
  return null;
}
