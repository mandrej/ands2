part of 'user_bloc.dart';

final List<String> admins = [
  'milan.andrejevic@gmail.com',
  'mihailo.genije@gmail.com',
];
final List<String> family = [
  'milan.andrejevic@gmail.com',
  'mihailo.genije@gmail.com',
  'ana.devic@gmail.com',
  'dannytaboo@gmail.com',
  'svetlana.andrejevic@gmail.com',
  '011.nina@gmail.com',
  'bogdan.andrejevic16@gmail.com',
  'zile.zikson@gmail.com',
];

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserAuthenticated extends UserState {
  final my.User user;
  const UserAuthenticated(this.user);

  @override
  List<Object?> get props => [user];

  factory UserAuthenticated.fromMap(Map<String, dynamic> map) {
    return UserAuthenticated(
      my.User.fromMap(map['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {'status': 'authenticated', 'user': user.toMap()};
  }
}

extension UserStateSerialization on UserState {
  static UserState fromMap(Map<String, dynamic>? map) {
    if (map == null) return UserInitial();
    if (map['status'] == 'authenticated' && map['user'] != null) {
      return UserAuthenticated(
        my.User.fromMap(Map<String, dynamic>.from(map['user'])),
      );
    }
    return UserInitial();
  }
}
