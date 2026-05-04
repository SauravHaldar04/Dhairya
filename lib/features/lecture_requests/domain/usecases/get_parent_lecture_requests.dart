import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lecture_request_entity.dart';
import '../repository/lecture_request_repository.dart';

class GetParentLectureRequests
    implements Usecase<List<LectureRequestEntity>, String> {
  final LectureRequestRepository repository;

  GetParentLectureRequests(this.repository);

  @override
  Future<Either<Failure, List<LectureRequestEntity>>> call(
      String parentId) async {
    return await repository.getParentLectureRequests(parentId);
  }
}
