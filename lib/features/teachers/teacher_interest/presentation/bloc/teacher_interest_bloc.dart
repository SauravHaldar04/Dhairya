import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/usecases/get_pending_interests.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/usecases/update_interest_status.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_event.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_state.dart';

class TeacherInterestBloc extends Bloc<TeacherInterestEvent, TeacherInterestState> {
  final GetPendingInterests _getPendingInterests;
  final UpdateInterestStatus _updateInterestStatus;

  TeacherInterestBloc({
    required GetPendingInterests getPendingInterests,
    required UpdateInterestStatus updateInterestStatus,
  })  : _getPendingInterests = getPendingInterests,
        _updateInterestStatus = updateInterestStatus,
        super(TeacherInterestInitial()) {
    on<FetchPendingInterests>(_onFetchPendingInterests);
    on<UpdateInterestStatusEvent>(_onUpdateInterestStatus);
  }

  Future<void> _onFetchPendingInterests(FetchPendingInterests event, Emitter<TeacherInterestState> emit) async {
    emit(TeacherInterestLoading());
    final res = await _getPendingInterests(event.teacherUid);
    res.fold(
      (failure) => emit(TeacherInterestError(failure.message)),
      (interests) => emit(TeacherInterestLoaded(interests)),
    );
  }

  Future<void> _onUpdateInterestStatus(UpdateInterestStatusEvent event, Emitter<TeacherInterestState> emit) async {
    final currentState = state;
    emit(TeacherInterestLoading());
    final res = await _updateInterestStatus(UpdateInterestStatusParams(
      interestId: event.interestId,
      status: event.status,
    ));
    res.fold(
      (failure) {
        emit(TeacherInterestError(failure.message));
        if (currentState is TeacherInterestLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(TeacherInterestStatusUpdated(event.interestId, event.status));
        // We will refetch from UI after this state is emitted.
      },
    );
  }
}
