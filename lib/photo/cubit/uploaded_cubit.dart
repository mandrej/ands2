import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../helpers/common.dart';
import '../models/photo.dart';

part 'uploaded_state.dart';

void removeFromStorage(String fileName) {
  final photoRef = FirebaseStorage.instance.ref().child(fileName);
  photoRef.delete().catchError((e) {
    print('Error deleting file: $e');
  });
  final thumbRef = FirebaseStorage.instance
      .ref()
      .child('/thumbnails')
      .child('/${thumbFileName(photoRef.name)}');
  thumbRef.delete().catchError((e) {
    print('Error deleting thumbnail: $e');
  });
}

class UploadedCubit extends HydratedCubit<UploadedState> {
  UploadedCubit() : super(const UploadedInitial()) {
    print('UploadedCubit constructor called');
  }

  List<Photo> get photos {
    if (state is UploadedLoaded) {
      return (state as UploadedLoaded).photos;
    }
    return [];
  }

  void addUploaded(Photo record) {
    final currentPhotos = photos;
    if (!currentPhotos.any((item) => item.filename == record.filename)) {
      print('Adding new record: ${record.filename}');
      emit(UploadedLoaded([...currentPhotos, record]));
    } else {
      print('Record already exists: ${record.filename}');
    }
  }

  void removeUploaded(Photo record) {
    doneUploaded(record);
    removeFromStorage(record.filename);
  }

  bool contains(Photo photo) {
    if (state is UploadedLoaded) {
      return (state as UploadedLoaded).photos.any(
        (p) => p.filename == photo.filename,
      );
    }
    return false;
  }

  void doneUploaded(Photo record) {
    final currentPhotos = photos;
    emit(
      UploadedLoaded(
        currentPhotos
            .where((item) => item.filename != record.filename)
            .toList(),
      ),
    );
  }

  @override
  UploadedState? fromJson(Map<String, dynamic> json) {
    final files = json['uploaded'];
    if (files is List) {
      final photos =
          files
              .map((item) => Photo.fromMap(item as Map<String, dynamic>))
              .toList();
      return UploadedLoaded(photos);
    }
    return const UploadedInitial();
  }

  @override
  Map<String, dynamic>? toJson(UploadedState state) {
    if (state is UploadedLoaded) {
      return {
        'uploaded': state.photos.map((record) => record.toMap()).toList(),
      };
    }
    return null;
  }
}
