part of 'available_values_bloc.dart';

final class AvailableValuesState extends Equatable {
  final Values? values;
  final bool loading;
  final String? error;

  const AvailableValuesState({this.values, this.loading = false, this.error});

  Map<String, dynamic> toMap() => {
    'values': values?.toMap(),
    'loading': loading,
    'error': error,
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
    );
  }

  @override
  List<Object> get props => [];
}

final class AvailableValuesInitial extends AvailableValuesState {}
