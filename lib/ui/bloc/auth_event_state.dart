import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- EVENTS ---

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const SignUpEvent({required this.name, required this.email, required this.password});

  @override
  List<Object?> get props => [name, email, password];
}

class GoogleSignInEvent extends AuthEvent {}

class SignOutEvent extends AuthEvent {}

// --- STATES ---

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}
