part of 'record_bloc.dart';

abstract class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object?> get props => [];
}

class RecordFetched extends RecordEvent {
  final FindState? findState;

  const RecordFetched({this.findState});

  @override
  List<Object?> get props => [findState];
}

class RecordClear extends RecordEvent {}
