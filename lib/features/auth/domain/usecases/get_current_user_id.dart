import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCurrentUserId implements Usecase<String, NoParams> {
  final AuthRepository repository;

  GetCurrentUserId(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    final result = await repository.getCurrentUser();
    return result.fold(
      (failure) => Left(failure),
      (user) => Right(user.uid),
    );
  }
}
