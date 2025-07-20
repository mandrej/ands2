import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String displayName;
  final String email;
  final String uid;
  final bool isAuthenticated;
  final bool isAdmin;
  final bool isFamily;

  const User({
    required this.displayName,
    required this.email,
    required this.uid,
    required this.isAuthenticated,
    required this.isAdmin,
    required this.isFamily,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      uid: json['uid'] as String,
      isAuthenticated: json['isAuthenticated'] as bool,
      isAdmin: json['isAdmin'] as bool,
      isFamily: json['isFamily'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'uid': uid,
      'isAuthenticated': isAuthenticated,
      'isAdmin': isAdmin,
      'isFamily': isFamily,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'uid': uid,
      'isAuthenticated': isAuthenticated,
      'isAdmin': isAdmin,
      'isFamily': isFamily,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      uid: map['uid'] as String,
      isAuthenticated: map['isAuthenticated'] as bool,
      isAdmin: map['isAdmin'] as bool,
      isFamily: map['isFamily'] as bool,
    );
  }

  @override
  List<Object?> get props => [
    displayName,
    email,
    uid,
    isAuthenticated,
    isAdmin,
    isFamily,
  ];
}
