part of 'uploadphoto_bloc.dart';

abstract class UploadphotoEvent extends Equatable {
  const UploadphotoEvent();

  @override
  List<Object> get props => [];
}

class AddUploaded extends UploadphotoEvent {
  final Photo photo;

  const AddUploaded(this.photo);

  @override
  List<Object> get props => [photo];
}

class RemoveUploaded extends UploadphotoEvent {
  final Photo photo;

  const RemoveUploaded(this.photo);

  @override
  List<Object> get props => [photo];
}
