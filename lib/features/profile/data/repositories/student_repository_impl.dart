import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/network/check_internet_connection.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/features/profile/data/datasources/student_remote_datasource.dart';
import 'package:aparna_education/features/profile/domain/entities/student_entity.dart';
import 'package:aparna_education/features/profile/domain/repositories/student_repository.dart';
import 'package:fpdart/fpdart.dart';

class StudentRepositoryImpl implements StudentRepository {
  final CheckInternetConnection checkInternetConnection;
  final StudentRemoteDatasource studentRemoteDatasource;
  
  StudentRepositoryImpl(
    this.checkInternetConnection,
    this.studentRemoteDatasource,
  );
  
  @override
  Future<Either<Failure, Success>> addStudent({
    required String firstName,
    required String middleName,
    required String lastName,
    required String standard,
    required List<String> subjects,
    required String board,
    required String medium,
  }) async {
    try {
      bool isConnected = await checkInternetConnection.isConnected;
      if (!isConnected) {
        return Left(Failure('No internet connection'));
      }
      
      await studentRemoteDatasource.addStudent(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        standard: standard,
        subjects: subjects,
        board: board,
        medium: medium,
      );
      
      return Right(Success("Student added successfully"));
    } on ServerException catch (e) {
      return Left(Failure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<Student>>> getStudentsByParent(String parentId) async {
    try {
      bool isConnected = await checkInternetConnection.isConnected;
      if (!isConnected) {
        return Left(Failure('No internet connection'));
      }
      
      final students = await studentRemoteDatasource.getStudentsByParent(parentId);
      return Right(students);
    } on ServerException catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
