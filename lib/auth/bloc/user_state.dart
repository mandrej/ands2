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

  bool get isAdmin;
  bool get isFamily;
  bool get isEditing;

  @override
  List<Object?> get props => [];

  get user => null;
}

class UserInitial extends UserState {
  @override
  final bool isEditing;
  const UserInitial({this.isEditing = false});

  @override
  bool get isAdmin => false;

  @override
  bool get isFamily => false;

  @override
  List<Object?> get props => [isEditing];

  Map<String, dynamic> toMap() => {'status': 'initial', 'isEditing': isEditing};
}

class UserAuthenticated extends UserState {
  final my.User user;
  @override
  final bool isEditing;
  const UserAuthenticated(this.user, {this.isEditing = false});

  @override
  bool get isAdmin => user.isAdmin;

  @override
  bool get isFamily => user.isFamily;

  @override
  List<Object?> get props => [user, isEditing];

  factory UserAuthenticated.fromMap(Map<String, dynamic> map) {
    return UserAuthenticated(
      my.User.fromMap(map['user'] as Map<String, dynamic>),
      isEditing: map['isEditing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': 'authenticated',
      'user': user.toMap(),
      'isEditing': isEditing,
    };
  }
}

extension UserStateSerialization on UserState {
  static UserState fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserInitial();
    if (map['status'] == 'authenticated' && map['user'] != null) {
      return UserAuthenticated(
        my.User.fromMap(Map<String, dynamic>.from(map['user'])),
        isEditing: map['isEditing'] as bool? ?? false,
      );
    }
    return UserInitial(isEditing: map['isEditing'] as bool? ?? false);
  }
}
