sealed class TeacherInterestEvent {
  const TeacherInterestEvent();
}

class FetchPendingInterests extends TeacherInterestEvent {
  final String teacherUid;
  const FetchPendingInterests(this.teacherUid);
}

class UpdateInterestStatusEvent extends TeacherInterestEvent {
  final String interestId;
  final String status;
  const UpdateInterestStatusEvent(this.interestId, this.status);
}
