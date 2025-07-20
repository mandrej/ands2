part of 'first_photo_cubit.dart';

class FirstRecordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FirstRecordInitial extends FirstRecordState {}

class FirstRecordLoading extends FirstRecordState {}

class FirstRecordLoaded extends FirstRecordState {
  final Photo photo;

  FirstRecordLoaded(this.photo);

  Map<String, dynamic> toMap() {
    return photo.toMap();
  }

  static FirstRecordLoaded fromMap(Map<String, dynamic> map) {
    return FirstRecordLoaded(Photo.fromMap(map));
  }

  @override
  List<Object?> get props => [photo];
}

class FirstRecordEmpty extends FirstRecordState {}

class FirstRecordError extends FirstRecordState {
  final String message;

  FirstRecordError(this.message);

  @override
  List<Object?> get props => [message];
}
