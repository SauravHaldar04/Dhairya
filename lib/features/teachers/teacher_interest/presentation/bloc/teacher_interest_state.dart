import 'package:aparna_education/features/teachers/teacher_interest/domain/entities/teacher_interest_entity.dart';

sealed class TeacherInterestState {
  const TeacherInterestState();
}

class TeacherInterestInitial extends TeacherInterestState {}

class TeacherInterestLoading extends TeacherInterestState {}

class TeacherInterestLoaded extends TeacherInterestState {
  final List<TeacherInterestEntity> interests;
  const TeacherInterestLoaded(this.interests);
}

class TeacherInterestError extends TeacherInterestState {
  final String message;
  const TeacherInterestError(this.message);
}

class TeacherInterestStatusUpdated extends TeacherInterestState {
  final String interestId;
  final String status;
  const TeacherInterestStatusUpdated(this.interestId, this.status);
}
