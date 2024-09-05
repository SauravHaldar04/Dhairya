part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileSuccess extends ProfileState {
  final String message;
  ProfileSuccess(this.message);
}

final class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure(this.message);
}
