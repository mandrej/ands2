import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/user.dart' as my;

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends HydratedBloc<UserEvent, UserState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserBloc() : super(const UserInitial()) {
    on<UserSignInRequested>(_onSignInRequested);
    on<UserSignOutRequested>(_onSignOutRequested);
    on<UserEdit>(_onUserEdit);
  }

  Future<void> _onSignInRequested(
    UserSignInRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      // Google sign-in with popup (web only)
      final googleProvider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(googleProvider);
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final email = firebaseUser.email ?? '';
        final isAdmin = admins.contains(email);
        final isFamily = family.contains(email);
        final user = my.User(
          uid: firebaseUser.uid,
          email: email,
          displayName: firebaseUser.displayName ?? '',
          isAuthenticated: true,
          isAdmin: isAdmin,
          isFamily: isFamily,
        );
        emit(UserAuthenticated(user));
      }
    } catch (e) {
      emit(const UserInitial());
    }
  }

  Future<void> _onSignOutRequested(
    UserSignOutRequested event,
    Emitter<UserState> emit,
  ) async {
    await _auth.signOut();
    emit(const UserInitial());
  }

  void _onUserEdit(UserEdit event, Emitter<UserState> emit) {
    final currentState = state;
    if (currentState is UserAuthenticated) {
      emit(
        UserAuthenticated(
          currentState.user,
          isEditing: !currentState.isEditing,
        ),
      );
    } else if (currentState is UserInitial) {
      emit(UserInitial(isEditing: !currentState.isEditing));
    }
  }

  @override
  UserState? fromJson(Map<String, dynamic> json) {
    return UserStateSerialization.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(UserState state) {
    return (state as dynamic).toMap();
  }
}
