import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';

class LogoutUser implements Usecase<void, NoParams> {
  final AuthRepository _repository;
  LogoutUser(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.logout();
  }
}
