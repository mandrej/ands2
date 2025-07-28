part of 'photo_bloc.dart';

abstract class PhotoEvent extends Equatable {
  const PhotoEvent();

  @override
  List<Object?> get props => [];
}

class PhotoFetched extends PhotoEvent {
  final FindState? findState;
  final String? fromFilename;

  const PhotoFetched({this.findState, this.fromFilename});

  @override
  List<Object?> get props => [findState];
}

class PhotoClear extends PhotoEvent {}

class PhotoDelete extends PhotoEvent {
  final String filename;

  const PhotoDelete(this.filename);

  @override
  List<Object> get props => [filename];
}

class PhotoAdd extends PhotoEvent {
  final Photo photo;

  const PhotoAdd(this.photo);

  @override
  List<Object> get props => [photo];
}

class PhotoUpdate extends PhotoEvent {
  final Photo photo;

  const PhotoUpdate(this.photo);

  @override
  List<Object> get props => [photo];
}

class PhotoPublish extends PhotoEvent {
  final Photo photo;
  final bool isPublished;

  const PhotoPublish(this.photo, this.isPublished);

  @override
  List<Object> get props => [photo, isPublished];
}
