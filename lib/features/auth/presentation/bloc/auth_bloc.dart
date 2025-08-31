// auth_bloc.dart

import 'dart:async';

import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/core/usecase/current_user.dart';
import 'package:aparna_education/features/auth/domain/usecases/is_user_email_verified.dart';
import 'package:aparna_education/features/auth/domain/usecases/update_email_verification.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_login.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_signup.dart';
import 'package:aparna_education/features/auth/domain/usecases/verify_user_email.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Bloc responsible for handling authentication events and states.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignup _userSignup;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  //final GoogleLogin _googleSignIn;
  final VerifyUserEmail _verifyUserEmail;
  //final GetFirebaseAuth _getFirebaseAuth;
  final IsUserEmailVerified _isUserEmailVerified;
  final Logger _logger;
  final UpdateEmailVerification _updateEmailVerification;

  Timer? _emailVerificationTimer;

  /// Constructor with dependency injection for various use cases and Logger.
  AuthBloc({
    required UpdateEmailVerification updateEmailVerification,
    required IsUserEmailVerified isUserEmailVerified,
    required UserSignup userSignup,
    required UserLogin userLogin,
    // required GoogleLogin googleSignIn,
    required CurrentUser currentUser,
    required VerifyUserEmail verifyUserEmail,
    //required GetFirebaseAuth getFirebaseAuth,
    required Logger logger,
  }) : _updateEmailVerification = updateEmailVerification,
       _userSignup = userSignup,
       _isUserEmailVerified = isUserEmailVerified,
       _userLogin = userLogin,
       //_googleSignIn = googleSignIn,
       _currentUser = currentUser,
       _verifyUserEmail = verifyUserEmail,
       //_getFirebaseAuth = getFirebaseAuth,
       _logger = logger,
       super(AuthInitial()) {
    // Register event handlers
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogIn>(_onAuthLogIn);
    on<AuthGoogleSignIn>(_onGoogleSignIn);
    on<AuthIsUserLoggedIn>(_onIsUserLoggedIn);
    on<AuthEmailVerification>(_onEmailVerification);
    on<AuthEmailVerificationCompleted>(_onEmailVerificationCompleted);
    on<AuthEmailVerificationFailed>(_onEmailVerificationFailed);
    on<AuthIsUserEmailVerified>(_onIsUserEmailVerified);
  }

  @override
  Future<void> close() {
    _emailVerificationTimer?.cancel();
    _logger.i('AuthBloc is being closed and timers are canceled.');
    return super.close();
  }

  /// Handles the [AuthSignUp] event.
  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    _logger.i('Handling AuthSignUp event for email: ${event.email}');
    final result = await _userSignup(UserSignupParams(
        middleName: event.middleName,
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName));
    result.fold(
      (failure) {
        _logger.e('AuthSignUp failed: ${failure.message}');
        emit(AuthFailure(failure.message));
      },
      (user) {
        _logger.i('AuthSignUp succeeded for user: ${user.email}');
        emit(AuthSuccess(user));
      },
    );
  }

  /// Handles the [AuthLogIn] event.
  void _onAuthLogIn(AuthLogIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    _logger.i('Handling AuthLogIn event for email: ${event.email}');
    final result = await _userLogin(UserLoginParams(
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) {
        _logger.e('AuthLogIn failed: ${failure.message}');
        emit(AuthFailure(failure.message));
      },
      (user) {
        _logger.i('AuthLogIn succeeded for user: ${user.email}');
        emit(AuthSuccess(user));
      },
    );
  }

  /// Handles the [AuthGoogleSignIn] event with empty implementation.
  void _onGoogleSignIn(AuthGoogleSignIn event, Emitter<AuthState> emit) async {
    _logger.i('AuthGoogleSignIn event received - not implemented yet');
    emit(AuthFailure('Google Sign-In not implemented yet'));
  }

  /// Handles the [AuthIsUserLoggedIn] event.
  void _onIsUserLoggedIn(
      AuthIsUserLoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    _logger.i('Handling AuthIsUserLoggedIn event');
    final result = await _currentUser(NoParams());
    result.fold(
      (failure) {
        _logger.e('AuthIsUserLoggedIn failed: ${failure.message}');
        emit(AuthFailure(failure.message));
      },
      (user) {
        _logger.i('User is logged in: ${user.email} ${user.emailVerified}');
        print('User is logged in: ${user.email} ${user.emailVerified}');
        emit(AuthUserLoggedIn(user));
        // if (user.emailVerified) {
        //   emit(AuthEmailVerified());
        //   _logger.i('User email is verified.');
        // } else {
        //   emit(AuthUserLoggedIn(user));
        // }
        
      },
    );
  }

  /// Handles the [AuthEmailVerification] event.
  void _onEmailVerification(
      AuthEmailVerification event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    _logger.i('Handling AuthEmailVerification event');
    try {
      final verifyResult = await _verifyUserEmail(NoParams());
      verifyResult.fold(
        (failure) {
          _logger.e('Email verification failed: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (success) {
          if (success) {
            _logger.i('Email verification sent successfully.');
            emit(AuthEmailVerificationInProgress());
            _startEmailVerificationPolling();
          } else {
            _logger.e('Failed to send email verification.');
            emit(AuthFailure('Email not sent'));
          }
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during email verification: $e');
      emit(AuthFailure('Unexpected error: $e'));
    }
  }

  /// Initiates polling to check if the user's email has been verified.
  void _startEmailVerificationPolling() {
  const timeout = Duration(seconds: 30);
  const pollInterval = Duration(seconds: 2);
  int attempts = 0;

  _emailVerificationTimer = Timer.periodic(pollInterval, (timer) async {
    attempts++;
    _logger.i('Email verification polling attempt: $attempts');

    if (attempts * pollInterval.inSeconds >= timeout.inSeconds) {
      _logger.w('Email verification timed out.');
      timer.cancel();
      add(AuthEmailVerificationFailed('Email verification timed out'));
      return;
    }

    try {
      // Use your usecase to check email verification status from Supabase
      final isVerifiedResult = await _isUserEmailVerified(NoParams());
      isVerifiedResult.fold(
        (failure) {
          _logger.e('Failed to check email verification: ${failure.message}');
          timer.cancel();
          add(AuthEmailVerificationFailed(failure.message));
        },
        (isVerified) async {
          if (isVerified) {
            _logger.i('User email is verified (Supabase).');
            timer.cancel();
            await _updateEmailVerification(NoParams());
            add(AuthEmailVerificationCompleted());
          }
        },
      );
    } catch (e) {
      _logger.e('Error during email verification polling: $e');
      timer.cancel();
      add(AuthEmailVerificationFailed('Error during verification: $e'));
    }
  });
}

  /// Handles the [AuthEmailVerificationCompleted] event.
  void _onEmailVerificationCompleted(
      AuthEmailVerificationCompleted event, Emitter<AuthState> emit) {
    _logger.i('Handling AuthEmailVerificationCompleted event');
    emit(AuthEmailVerified());
  }

  /// Handles the [AuthEmailVerificationFailed] event.
  void _onEmailVerificationFailed(
      AuthEmailVerificationFailed event, Emitter<AuthState> emit) {
    _logger.e('Handling AuthEmailVerificationFailed event: ${event.message}');
    emit(AuthFailure(event.message));
  }

  /// Handles the [AuthIsUserEmailVerified] event.
  void _onIsUserEmailVerified(
      AuthIsUserEmailVerified event, Emitter<AuthState> emit) async {
    _logger.i('Handling AuthIsUserEmailVerified event');
    try {
      final isVerified = await _isUserEmailVerified(NoParams());
      isVerified.fold(
        (failure) {
          _logger.e('isUserEmailVerified failed: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (verified) {
          if (verified) {
            _logger.i('User email is verified.');
            emit(AuthEmailVerified());
          } else {
            _logger.w('User email is not verified.');
            emit(AuthEmailVerificationFailedState('Email not verified'));
          }
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during isUserEmailVerified: $e');
      emit(AuthFailure('Unexpected error: $e'));
    }
  }
}
