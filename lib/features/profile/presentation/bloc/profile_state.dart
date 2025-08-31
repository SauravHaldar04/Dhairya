part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final String message;

  ProfileSuccess(this.message);
}

class ProfileFailure extends ProfileState {
  final String message;

  ProfileFailure(this.message);
}

class ProfileUser extends ProfileState {
  final User user;

  ProfileUser(this.user);
}

// Adding the missing state
class ParentDataLoaded extends ProfileState {
  final Parent parent;

  ParentDataLoaded(this.parent);
}

class StudentsLoaded extends ProfileState {
  final List<Student> students;

  StudentsLoaded({required this.students});

  @override
  List<Object?> get props => [students];
}
