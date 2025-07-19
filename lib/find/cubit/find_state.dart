part of 'find_cubit.dart';

sealed class FindState extends Equatable {
  const FindState();

  Find get find;

  @override
  List<Object> get props => [];
}

final class FindInitial extends FindState {
  @override
  Find get find => const Find();
}

final class FindUpdated extends FindState {
  const FindUpdated({required this.data});

  final Map<String, dynamic> data;

  @override
  Find get find => Find.fromJson(data);

  @override
  List<Object> get props => [data];
}
