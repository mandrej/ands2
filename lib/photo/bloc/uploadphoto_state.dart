part of 'uploadphoto_bloc.dart';

abstract class UploadphotoState extends Equatable {
  const UploadphotoState();

  @override
  List<Object> get props => [];
}

class UploadphotoInitial extends UploadphotoState {
  const UploadphotoInitial();
}

class UploadphotoLoaded extends UploadphotoState {
  final List<Photo> photos;

  const UploadphotoLoaded(this.photos);

  @override
  List<Object> get props => [photos];

  bool get isEmpty => photos.isEmpty;
  bool get isNotEmpty => photos.isNotEmpty;
  int get length => photos.length;
  Photo operator [](int index) => photos[index];
}
