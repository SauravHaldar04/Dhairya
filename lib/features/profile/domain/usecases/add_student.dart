import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/success/success.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';
import 'package:aparna_education/features/profile/domain/repositories/student_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddStudent implements Usecase<Success, AddStudentParams> {
  final StudentRepository repository;
  final AuthRepository authRepository;

  AddStudent(this.repository, this.authRepository);

  @override
  Future<Either<Failure, Success>> call(AddStudentParams params) async {
    // Get current user to validate parent context
    final currentUserResult = await authRepository.getCurrentUser();

    return currentUserResult.fold(
      (failure) => Left(failure),
      (currentUser) async {
        // Additional validation: Ensure we have a valid parent context
        if (currentUser.uid.isEmpty) {
          return Left(Failure('Invalid parent authentication'));
        }

        // Validate input parameters
        if (params.firstName.trim().isEmpty || params.lastName.trim().isEmpty) {
          return Left(Failure('Student first name and last name are required'));
        }

        if (params.standard.trim().isEmpty) {
          return Left(Failure('Student standard is required'));
        }

        return await repository.addStudent(
          firstName: params.firstName.trim(),
          middleName: params.middleName.trim(),
          lastName: params.lastName.trim(),
          standard: params.standard.trim(),
          subjects: params.subjects,
          board: params.board.trim(),
          medium: params.medium.trim(),
        );
      },
    );
  }
}

class AddStudentParams {
  final String firstName;
  final String middleName;
  final String lastName;
  final String standard;
  final List<String> subjects;
  final String board;
  final String medium;

  AddStudentParams({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.standard,
    required this.subjects,
    required this.board,
    required this.medium,
  });
}
