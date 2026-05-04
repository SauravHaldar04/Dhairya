import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/network/check_internet_connection.dart';
import 'package:aparna_education/features/teachers/teacher_interest/data/datasources/teacher_interest_remote_datasource.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/entities/teacher_interest_entity.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/repositories/teacher_interest_repository.dart';
import 'package:fpdart/fpdart.dart';

class TeacherInterestRepositoryImpl implements TeacherInterestRepository {
  final TeacherInterestRemoteDataSource remoteDataSource;
  final CheckInternetConnection checkInternetConnection;

  TeacherInterestRepositoryImpl(this.remoteDataSource, this.checkInternetConnection);

  @override
  Future<Either<Failure, List<TeacherInterestEntity>>> getPendingInterests(String teacherUid) async {
    try {
      if (!await checkInternetConnection.isConnected) {
        return left(Failure('No internet connection'));
      }
      final interests = await remoteDataSource.getPendingInterests(teacherUid);
      return right(interests);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateInterestStatus(String interestId, String status) async {
    try {
      if (!await checkInternetConnection.isConnected) {
        return left(Failure('No internet connection'));
      }
      await remoteDataSource.updateInterestStatus(interestId, status);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
