import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/lectures_repository.dart';

/// Use Case: Delete (soft delete) recurring lecture template
/// Marks template as inactive, stops generating virtual instances
class DeleteTemplate implements Usecase<void, DeleteTemplateParams> {
  final LecturesRepository repository;

  DeleteTemplate(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTemplateParams params) async {
    final result = await repository.deleteTemplate(params.templateId);
    
    return result.fold(
      (serverException) => Left(Failure(serverException.message)),
      (success) => const Right(null),
    );
  }
}

class DeleteTemplateParams {
  final String templateId;

  DeleteTemplateParams({required this.templateId});
}
