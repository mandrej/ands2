part of 'last_photo_cubit.dart';

class LastRecordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LastRecordInitial extends LastRecordState {}

class LastRecordLoading extends LastRecordState {}

class LastRecordLoaded extends LastRecordState {
  final Photo photo;

  LastRecordLoaded(this.photo);

  Map<String, dynamic> toMap() {
    return photo.toMap();
  }

  static LastRecordLoaded fromMap(Map<String, dynamic> map) {
    return LastRecordLoaded(Photo.fromMap(map));
  }

  @override
  List<Object?> get props => [photo];
}

class LastRecordEmpty extends LastRecordState {}

class LastRecordError extends LastRecordState {
  final String message;

  LastRecordError(this.message);

  @override
  List<Object?> get props => [message];
}
