import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/repositories/teacher_interest_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateInterestStatusParams {
  final String interestId;
  final String status;
  const UpdateInterestStatusParams({required this.interestId, required this.status});
}

class UpdateInterestStatus implements Usecase<void, UpdateInterestStatusParams> {
  final TeacherInterestRepository repository;

  UpdateInterestStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateInterestStatusParams params) async {
    return await repository.updateInterestStatus(params.interestId, params.status);
  }
}
