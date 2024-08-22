import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_user_state.dart';

class AuthUserCubit extends Cubit<AuthUserState> {
  AuthUserCubit() : super(AuthUserInitial());
  // void updateUser(User? user) {
  //   if (user == null) {
  //     emit(AuthUserInitial());
  //   } else {
  //     emit(AuthUserLoggedIn(user));
  //   }
  // }
  
}
