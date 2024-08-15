part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUp extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  AuthSignUp(this.email, this.password,  this.firstName, this.lastName);
}

final class AuthLogIn extends AuthEvent {
  final String email;
  final String password;
  AuthLogIn(this.email, this.password);
}

final class AuthEmailVerification extends AuthEvent {

}

final class AuthGoogleSignIn extends AuthEvent {

}

final class AuthIsUserLoggedIn extends AuthEvent {

}


class AuthEmailVerificationCompleted extends AuthEvent {}

class AuthEmailVerificationFailed extends AuthEvent {
  final String message;
  AuthEmailVerificationFailed(this.message);
}

