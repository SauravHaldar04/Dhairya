import 'dart:io';

import 'package:aparna_education/features/profile/domain/usecases/add_teacher.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AddTeacher _addTeacher;
  ProfileBloc({
    required AddTeacher addTeacher,
  })  : _addTeacher = addTeacher,
        super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) => emit(ProfileLoading()));
    on<CreateProfile>(_onCreateProfile);
  }
  void _onCreateProfile(CreateProfile event, Emitter<ProfileState> emit) async {
    final result = await _addTeacher.call(AddTeacherParams(
        firstName: event.address,
        lastName: event.lastName,
        middleName: event.middleName,
        subjects: event.subjects,
        profilePic: event.profilePic,
        board: event.board,
        address: event.address,
        city: event.city,
        state: event.state,
        country: event.country,
        pincode: event.pincode,
        dob: event.dob,
        gender: event.gender,
        phoneNumber: event.phoneNumber,
        workExp: event.workExp,
        resume: event.resume));
    result.fold((l) => emit(ProfileFailure(l.message)),
        (r) => emit(ProfileSuccess(r.message)));
  }
}
