import 'dart:io';

import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/usecase/current_user.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/profile/domain/usecases/add_language_learner.dart';
import 'package:aparna_education/features/profile/domain/usecases/add_parent.dart';
import 'package:aparna_education/features/profile/domain/usecases/add_teacher.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AddTeacher _addTeacher;
  final CurrentUser _getCurrentUser;
  final AddParent _addParent;
  final AddLanguageLearner _addLanguageLearner;

  ProfileBloc({
    required AddParent addParent,
    required AddTeacher addTeacher,
    required CurrentUser getCurrentUser,
    required AddLanguageLearner addLanguageLearner,
  })  : _addTeacher = addTeacher,
        _getCurrentUser = getCurrentUser,
        _addParent = addParent,
        _addLanguageLearner = addLanguageLearner,
        super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) => emit(ProfileLoading()));
    on<CreateProfile>(_onCreateProfile);
    on<GetCurrentUser>(_onGetCurrentUser);
    on<CreateParentProfile>(_onCreateParentProfile);
    on<CreateLanguageLearnerProfile>(_onCreateLanguageLearnerProfile);
  }

  void _onCreateProfile(CreateProfile event, Emitter<ProfileState> emit) async {
    final result = await _addTeacher.call(AddTeacherParams(
        firstName: event.firstName,
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

  void _onGetCurrentUser(
      GetCurrentUser event, Emitter<ProfileState> emit) async {
    final result = await _getCurrentUser.call(NoParams());
    result.fold((l) => emit(ProfileFailure(l.message)),
        (r) => emit(ProfileUser(r)));
  }

  void _onCreateParentProfile(
      CreateParentProfile event, Emitter<ProfileState> emit) async {
    final result = await _addParent.call(AddParentParams(
        firstName: event.firstName,
        middleName: event.middleName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
        address: event.address,
        city: event.city,
        state: event.state,
        country: event.country,
        pincode: event.pincode,
        gender: event.gender,
        dob: event.dob,
        profilePic: event.profilePic,
        occupation: event.occupation));
    result.fold((l) => emit(ProfileFailure(l.message)),
        (r) => emit(ProfileSuccess(r.message)));
  }

  void _onCreateLanguageLearnerProfile(
      CreateLanguageLearnerProfile event, Emitter<ProfileState> emit) async {
    final result = await _addLanguageLearner.call(AddLanguageLearnerParams(
      firstName: event.firstName,
      middleName: event.middleName,
      lastName: event.lastName,
      phoneNumber: event.phoneNumber,
      address: event.address,
      city: event.city,
      state: event.state,
      country: event.country,
      pincode: event.pincode,
      gender: event.gender,
      dob: event.dob,
      profilePic: event.profilePic,
      occupation: event.occupation,
      languagesKnown: event.languagesKnown,
      languagesToLearn: event.languagesToLearn,
    ));
    result.fold((l) => emit(ProfileFailure(l.message)),
        (r) => emit(ProfileSuccess(r.message)));
  }
}
