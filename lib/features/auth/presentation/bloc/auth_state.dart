part of 'auth_bloc.dart';
sealed class AuthState {
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

final class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}
final class AuthEmailVerified extends AuthState {} 

class AuthEmailVerificationInProgress extends AuthState {}

class AuthEmailVerificationFailedState extends AuthState {
  final String message;
  AuthEmailVerificationFailedState(this.message);
}
final class AuthUserLoggedIn extends AuthState {
  final User user;
  AuthUserLoggedIn(this.user);
}



