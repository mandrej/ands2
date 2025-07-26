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
