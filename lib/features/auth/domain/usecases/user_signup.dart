import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';

import 'package:fpdart/fpdart.dart';

class UserSignup implements Usecase<User, UserSignupParams> {
  final AuthRepository authRepository;
  const UserSignup(this.authRepository);
  @override
  Future<Either<Failure, User>> call(UserSignupParams params) async {
    return await authRepository.signInWithEmailAndPassword(
      lastName: params.lastName, firstName: params.firstName, email: params.email, password: params.password);
  }
}

class UserSignupParams {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  UserSignupParams(
      {required this.firstName,required this.lastName,  required this.email, required this.password});

}
