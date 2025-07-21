import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photo.dart';

part 'last_photo_state.dart';

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

class LastRecordCubit extends Cubit<LastRecordState> {
  LastRecordCubit() : super(LastRecordInitial());

  Future<void> fetchLastRecord() async {
    emit(LastRecordLoading());
    try {
      final photo = await getRecord('Photo', true);
      if (photo != null) {
        emit(LastRecordLoaded(photo));
      } else {
        emit(LastRecordEmpty());
      }
    } catch (e) {
      emit(LastRecordError(e.toString()));
    }
  }
}

@override
LastRecordState fromJson(Map<String, dynamic> json) {
  try {
    return LastRecordLoaded.fromMap(json);
  } catch (_) {
    return LastRecordInitial();
  }
}

@override
Map<String, dynamic>? toJson(LastRecordState state) {
  if (state is LastRecordLoaded) {
    return state.toMap();
  }
  return null;
}
