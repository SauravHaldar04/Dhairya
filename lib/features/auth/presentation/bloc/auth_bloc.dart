import 'package:aparna_education/core/cubits/auth_user/auth_user_cubit.dart';
import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/auth/domain/usecases/current_user.dart';
import 'package:aparna_education/features/auth/domain/usecases/google_login.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_login.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_signup.dart';
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

  AuthBloc(
      {required UserSignup userSignup,
      required UserLogin userLogin,
      required GoogleLogin googleSignIn,
      required CurrentUser currentUser,
      required AuthUserCubit authUserCubit})
      : _userSignup = userSignup,
        _userLogin = userLogin,
        _googleSignIn = googleSignIn,
        _currentUser = currentUser,
        _authUserCubit = authUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((event, emit)=>emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogIn>(_onAuthLogIn);
    on<AuthGoogleSignIn>(_onGoogleSignIn);
    on<AuthIsUserLoggedIn>(_onIsUserLoggedIn);
  }
  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _authUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }

  void _onIsUserLoggedIn(
      AuthIsUserLoggedIn event, Emitter<AuthState> emit) async {
    final result = await _currentUser(NoParams());
    result.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      print(user.email);
      _emitAuthSuccess(user, emit);
    });
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    final result = await _userSignup(UserSignupParams(
        email: event.email, password: event.password, firstName: event.firstName, lastName: event.lastName));
    result.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      _emitAuthSuccess(user, emit);
    });
  }

  void _onAuthLogIn(AuthLogIn event, Emitter<AuthState> emit) async {
    final result = await _userLogin(
        UserLoginParams(email: event.email, password: event.password));
    result.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      _emitAuthSuccess(user, emit);
    });
  }
  void _onGoogleSignIn(AuthGoogleSignIn event , Emitter<AuthState> emit)async{
    final result = await _googleSignIn(NoParams());
    result.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      _emitAuthSuccess(user, emit);
    });

  }
}
