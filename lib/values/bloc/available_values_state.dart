part of 'available_values_bloc.dart';

final class AvailableValuesState extends Equatable {
  final Values? values;
  final bool loading;
  final String? error;
  final AvailableValuesStatus status;

  const AvailableValuesState({
    this.values,
    this.loading = false,
    this.error,
    this.status = AvailableValuesStatus.initial,
  });

  AvailableValuesState copyWith({
    Values? values,
    bool? loading,
    String? error,
    AvailableValuesStatus? status,
  }) {
    return AvailableValuesState(
      values: values ?? this.values,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
    'values': values?.toMap(),
    'loading': loading,
    'error': error,
    'status': status.name,
  };

  Map<String, int>? get year => values?.year;
  Map<String, int>? get month => values?.month;
  Map<String, int>? get tags => values?.tags;
  Map<String, int>? get email => values?.email;
  Map<String, int>? get nick => values?.nick;
  Map<String, int>? get model => values?.model;
  Map<String, int>? get lens => values?.lens;

  factory AvailableValuesState.fromMap(Map<String, dynamic> map) {
    return AvailableValuesState(
      values:
          map['values'] != null
              ? Values.fromMap(Map<String, dynamic>.from(map['values']))
              : null,
      loading: map['loading'] ?? false,
      error: map['error'],
      status:
          map['status'] != null
              ? AvailableValuesStatus.values.firstWhere(
                (e) => e.name == map['status'],
                orElse: () => AvailableValuesStatus.initial,
              )
              : AvailableValuesStatus.initial,
    );
  }

  @override
  List<Object?> get props => [values, loading, error, status];
}

final class AvailableValuesInitial extends AvailableValuesState {}
