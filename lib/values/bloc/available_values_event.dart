part of 'available_values_bloc.dart';

sealed class AvailableValuesEvent extends Equatable {
  const AvailableValuesEvent();

  @override
  List<Object> get props => [];
}

class FetchAvailableValues extends AvailableValuesEvent {}
