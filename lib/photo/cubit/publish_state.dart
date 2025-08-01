part of 'publish_cubit.dart';

sealed class PublishState extends Equatable {
  const PublishState();

  @override
  List<Object> get props => [];
}

final class PublishInitial extends PublishState {
  const PublishInitial();

  @override
  List<Object> get props => [];
}

final class PublishLoaded extends PublishState {
  const PublishLoaded(this.photos);

  final List<Photo> photos;

  @override
  List<Object> get props => [photos];

  bool get isEmpty => photos.isEmpty;
  bool get isNotEmpty => photos.isNotEmpty;
  int get length => photos.length;
  Photo operator [](int index) => photos[index];
}
