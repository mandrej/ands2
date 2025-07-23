part of 'photo_bloc.dart';

enum PhotoStatus { initial, success, failure }

final class PhotoState extends Equatable {
  const PhotoState({
    this.status = PhotoStatus.initial,
    this.records = const <Photo>[],
    this.hasReachedMax = false,
    this.fromFilename = '',
  });

  final PhotoStatus status;
  final List<Photo> records;
  final bool hasReachedMax;
  final String fromFilename;

  PhotoState copyWith({
    PhotoStatus? status,
    List<Photo>? records,
    bool? hasReachedMax,
    String? fromFilename,
  }) {
    return PhotoState(
      status: status ?? this.status,
      records: records ?? this.records,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      fromFilename: fromFilename ?? this.fromFilename,
    );
  }

  @override
  String toString() {
    return '*** PhotoState { status: $status, hasReachedMax: $hasReachedMax, records: ${records.length}}';
  }

  @override
  List<Object> get props => [status, records, hasReachedMax, fromFilename];
}
