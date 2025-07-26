part of 'uploadphoto_bloc.dart';

sealed class UploadphotoState extends Equatable {
  const UploadphotoState();
  
  @override
  List<Object> get props => [];
}

final class UploadphotoInitial extends UploadphotoState {}
