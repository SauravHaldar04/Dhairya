import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';
import 'package:aparna_education/features/profile/domain/repositories/parent_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetParent implements Usecase<Parent, GetParentParams> {
  final ParentRepository repository;

  GetParent(this.repository);

  @override
  Future<Either<Failure, Parent>> call(GetParentParams params) {
    return repository.getParent(params.uid);
  }
}

class GetParentParams {
  final String uid;

  GetParentParams({required this.uid});
}
