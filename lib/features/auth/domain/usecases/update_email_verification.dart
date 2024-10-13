import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateEmailVerification implements Usecase<void, NoParams> {
  final AuthRepository repository;
  UpdateEmailVerification(this.repository);
  @override
  Future<Either<Failure,void>> call(NoParams params) {
    return repository.updateEmailVerification();
  }
}


