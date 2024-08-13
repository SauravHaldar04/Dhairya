import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class GoogleLogin implements Usecase<User,NoParams>{
  final AuthRepository repository;

  GoogleLogin(this.repository);

  @override
  Future<Either<Failure,User>> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}