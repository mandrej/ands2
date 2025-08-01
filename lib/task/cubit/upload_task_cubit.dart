import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

part 'upload_task_state.dart';

class UploadTaskCubit extends Cubit<UploadTaskState> {
  UploadTaskCubit() : super(const UploadTaskInitial()) {
    print('UploadTaskCubit constructor called');
  }

  /// Add an upload task to the list
  void add(firebase_storage.UploadTask task) {
    print('UploadTaskCubit.add called with task: ${task.snapshot.ref.name}');
    final currentState = state;
    List<firebase_storage.UploadTask> currentTasks = [];

    if (currentState is UploadTaskLoaded) {
      currentTasks = List.from(currentState.tasks);
    }

    currentTasks.add(task);
    print('Emitting UploadTaskLoaded with ${currentTasks.length} tasks');
    emit(UploadTaskLoaded(tasks: currentTasks));
  }

  /// Remove a specific upload task from the list
  void remove(firebase_storage.UploadTask task) {
    final currentState = state;

    if (currentState is UploadTaskLoaded) {
      final updatedTasks =
          currentState.tasks
              .where((existingTask) => existingTask != task)
              .toList();

      if (updatedTasks.isEmpty) {
        emit(const UploadTaskInitial());
      } else {
        emit(UploadTaskLoaded(tasks: updatedTasks));
      }
    }
  }

  /// Clear all upload tasks
  void clear() {
    emit(const UploadTaskInitial());
  }
}
