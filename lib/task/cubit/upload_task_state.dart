part of 'upload_task_cubit.dart';

sealed class UploadTaskState extends Equatable {
  const UploadTaskState();

  @override
  List<Object> get props => [];
}

final class UploadTaskInitial extends UploadTaskState {
  const UploadTaskInitial();

  @override
  List<Object> get props => [];
}

final class UploadTaskLoaded extends UploadTaskState {
  const UploadTaskLoaded({required this.tasks});

  final List<firebase_storage.UploadTask> tasks;

  @override
  List<Object> get props => [tasks];

  bool get isEmpty => tasks.isEmpty;
  bool get isNotEmpty => tasks.isNotEmpty;
  int get length => tasks.length;
  firebase_storage.UploadTask operator [](int index) => tasks[index];
}
