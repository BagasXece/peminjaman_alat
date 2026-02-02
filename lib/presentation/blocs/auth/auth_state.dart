
part of 'auth_cubit.dart';

abstract class AuthCState extends Equatable {
  const AuthCState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthCState {}

class AuthLoading extends AuthCState {}

class Authenticated extends AuthCState {
  final AppUser user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthCState {}

class AuthError extends AuthCState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
