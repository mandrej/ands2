import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../helpers/common.dart';
import '../models/photo.dart';

part 'publish_state.dart';

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

class PublishCubit extends HydratedCubit<PublishState> {
  PublishCubit() : super(const PublishInitial()) {
    print('PublishCubit constructor called');
  }

  List<Photo> get photos {
    if (state is PublishLoaded) {
      return (state as PublishLoaded).photos;
    }
    return [];
  }

  void add(Photo record) {
    print('PublishCubit.add called with record: ${record.filename}');
    final currentPhotos = photos;
    print('Current photos count: ${currentPhotos.length}');
    if (!currentPhotos.any((item) => item.filename == record.filename)) {
      print('Adding new record: ${record.filename}');
      emit(PublishLoaded([...currentPhotos, record]));
    } else {
      print('Record already exists: ${record.filename}');
    }
  }

  void removeUploaded(Photo record) {
    donePublish(record);
    removeFromStorage(record.filename);
  }

  void donePublish(Photo record) {
    final currentPhotos = photos;
    emit(
      PublishLoaded(
        currentPhotos
            .where((item) => item.filename != record.filename)
            .toList(),
      ),
    );
  }

  @override
  PublishState? fromJson(Map<String, dynamic> json) {
    final files = json['uploaded'];
    if (files is List) {
      final photos =
          files
              .map((item) => Photo.fromMap(item as Map<String, dynamic>))
              .toList();
      return PublishLoaded(photos);
    }
    return const PublishInitial();
  }

  @override
  Map<String, dynamic>? toJson(PublishState state) {
    if (state is PublishLoaded) {
      return {
        'uploaded': state.photos.map((record) => record.toMap()).toList(),
      };
    }
    return null;
  }
}
