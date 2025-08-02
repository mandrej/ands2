part of 'uploaded_cubit.dart';

sealed class UploadedState extends Equatable {
  const UploadedState();

  @override
  List<Object> get props => [];
}

final class UploadedInitial extends UploadedState {
  const UploadedInitial();

  @override
  List<Object> get props => [];
}

final class UploadedLoaded extends UploadedState {
  const UploadedLoaded(this.photos);

  final List<Photo> photos;

  @override
  List<Object> get props => [photos];

  bool get isEmpty => photos.isEmpty;
  bool get isNotEmpty => photos.isNotEmpty;
  int get length => photos.length;
  Photo operator [](int index) => photos[index];
}
