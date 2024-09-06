import 'dart:async';
import 'dart:math';

import 'package:aparna_education/core/cubits/auth_user/auth_user_cubit.dart';
import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/auth/domain/usecases/current_user.dart';
import 'package:aparna_education/features/auth/domain/usecases/get_firebase_auth.dart';
import 'package:aparna_education/features/auth/domain/usecases/google_login.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_login.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_signup.dart';
import 'package:aparna_education/features/auth/domain/usecases/verify_user_email.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignup _userSignup;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AuthUserCubit _authUserCubit;
  final GoogleLogin _googleSignIn;
  final VerifyUserEmail _verifyUserEmail;
  final GetFirebaseAuth _getFirebaseAuth;

  AuthBloc({
    required UserSignup userSignup,
    required UserLogin userLogin,
    required GoogleLogin googleSignIn,
    required CurrentUser currentUser,
    required AuthUserCubit authUserCubit,
    required VerifyUserEmail verifyUserEmail,
    required GetFirebaseAuth getFirebaseAuth,
  })  : _userSignup = userSignup,
        _userLogin = userLogin,
        _googleSignIn = googleSignIn,
        _currentUser = currentUser,
        _authUserCubit = authUserCubit,
        _verifyUserEmail = verifyUserEmail,
        _getFirebaseAuth = getFirebaseAuth,
        super(AuthInitial()) {
    on<AuthEvent>((event, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogIn>(_onAuthLogIn);
    on<AuthGoogleSignIn>(_onGoogleSignIn);
    on<AuthIsUserLoggedIn>(_onIsUserLoggedIn);
    on<AuthEmailVerification>(_onEmailVerification);
    on<AuthEmailVerificationCompleted>(_onEmailVerificationCompleted);
    on<AuthEmailVerificationFailed>(_onEmailVerificationFailed);
    on<AuthIsUserEmailVerified>(_onIsUserEmailVerified);
  }
  // void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
  //   _authUserCubit.updateUser(user);
  //   emit(AuthSuccess(user));
  // }

  void _onIsUserEmailVerified(
      AuthIsUserEmailVerified event, Emitter<AuthState> emit) async {
    // emit(AuthInitial());
    final result = await _verifyUserEmail(NoParams());
    result.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (success) {
      if (success) {
        emit(AuthEmailVerified());
      } else {
        emit(AuthEmailVerificationFailedState('Email not verified'));
      }
    });
  }

  Future<void> _onEmailVerification(
    AuthEmailVerification event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final verifyResult = await _verifyUserEmail(NoParams());
      await verifyResult.fold(
        (failure) async {
          emit(AuthFailure(failure.message));
        },
        (success) async {
          if (success) {
            emit(AuthEmailVerificationInProgress());
            _startEmailVerificationPolling();
          } else {
            emit(AuthFailure('Email not sent'));
          }
        },
      );
    } catch (e) {
      emit(AuthFailure('Unexpected error: $e'));
    }
  }

  void _startEmailVerificationPolling() {
    const timeout = Duration(seconds: 30);
    const pollInterval = Duration(seconds: 2);
    int attempts = 0;

    Timer.periodic(pollInterval, (timer) async {
      attempts++;
      if (attempts * pollInterval.inSeconds > timeout.inSeconds) {
        timer.cancel();
        add(AuthEmailVerificationFailed('Email verification timed out'));
        return;
      }

      try {
        final authResult = await _getFirebaseAuth(NoParams());
        await authResult.fold(
          (failure) async {
            timer.cancel();
            add(AuthEmailVerificationFailed(failure.message));
          },
          (firebaseAuth) async {
            await firebaseAuth.currentUser?.reload();
            if (firebaseAuth.currentUser?.emailVerified == true) {
              timer.cancel();
              add(AuthEmailVerificationCompleted());
            }
          },
        );
      } catch (e) {
        timer.cancel();
        add(AuthEmailVerificationFailed('Error during verification: $e'));
      }
    });
  }

  void _onIsUserLoggedIn(
      AuthIsUserLoggedIn event, Emitter<AuthState> emit) async {
    final result = await _currentUser(NoParams());
    result.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      print(user.email);
      emit(AuthUserLoggedIn(user));
    });
  }

  void _onEmailVerificationCompleted(
    AuthEmailVerificationCompleted event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthEmailVerified());
  }

  void _onEmailVerificationFailed(
    AuthEmailVerificationFailed event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthFailure(event.message));
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _userSignup(UserSignupParams(
      middleName: event.middleName,
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName));
    result.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      emit(AuthSuccess(user));
    });
  }

  void _onAuthLogIn(AuthLogIn event, Emitter<AuthState> emit) async {
    final result = await _userLogin(
        UserLoginParams(email: event.email, password: event.password));
    result.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      emit(AuthSuccess(user));
    });
  }

  void _onGoogleSignIn(AuthGoogleSignIn event, Emitter<AuthState> emit) async {
    final result = await _googleSignIn(NoParams());
    result.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      emit(AuthSuccess(user));
    });
  }
}
