part of 'record_bloc.dart';

enum RecordStatus { initial, success, failure }

final class RecordState extends Equatable {
  const RecordState({
    this.status = RecordStatus.initial,
    this.records = const <Record>[],
    this.hasReachedMax = false,
    this.fromFilename = '',
  });

  final RecordStatus status;
  final List<Record> records;
  final bool hasReachedMax;
  final String fromFilename;

  RecordState copyWith({
    RecordStatus? status,
    List<Record>? records,
    bool? hasReachedMax,
    String? fromFilename,
  }) {
    return RecordState(
      status: status ?? this.status,
      records: records ?? this.records,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      fromFilename: fromFilename ?? this.fromFilename,
    );
  }

  @override
  String toString() {
    return '\n*** RecordState { status: $status, hasReachedMax: $hasReachedMax, records: ${records.length}}';
  }

  @override
  List<Object> get props => [status, records, hasReachedMax, fromFilename];
}
