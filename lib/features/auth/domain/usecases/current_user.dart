
import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';

class CurrentUser implements Usecase<User,NoParams>{
  final AuthRepository repository;

  CurrentUser(this.repository);

  @override
  Future<Either<Failure,User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}