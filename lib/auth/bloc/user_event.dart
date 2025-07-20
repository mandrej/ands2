part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object> get props => [];
}

class UserSignInRequested extends UserEvent {
  @override
  List<Object> get props => [];
}

class UserSignOutRequested extends UserEvent {
  @override
  List<Object> get props => [];
}
