part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UsersLoaded extends UserState {
  final List<AppUser> users;
  const UsersLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

class UserCreated extends UserState {
  final AppUser user;
  const UserCreated(this.user);
  @override
  List<Object?> get props => [user];
}

class UserDeleted extends UserState {}

class UserUpdated extends UserState {
  final AppUser user;
  const UserUpdated(this.user);
  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);
  @override
  List<Object?> get props => [message];
}
