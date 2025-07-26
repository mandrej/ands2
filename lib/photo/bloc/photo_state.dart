part of 'photo_bloc.dart';

enum PhotoStatus { initial, success, failure }

final class PhotoState extends Equatable {
  const PhotoState({
    this.status = PhotoStatus.initial,
    this.records = const <Photo>[],
    this.fromFilename = '',
    this.findState,
  });

  final PhotoStatus status;
  final List<Photo> records;
  final String fromFilename;
  final FindState? findState;

  PhotoState copyWith({
    PhotoStatus? status,
    List<Photo>? records,
    String? fromFilename,
    FindState? findState,
  }) {
    return PhotoState(
      status: status ?? this.status,
      records: records ?? this.records,
      fromFilename: fromFilename ?? this.fromFilename,
      findState: findState ?? this.findState,
    );
  }

  @override
  String toString() {
    return '\n*** PhotoState { status: $status, records: ${records.length}}';
  }

  @override
  List<Object?> get props => [status, records, fromFilename, findState];
}
