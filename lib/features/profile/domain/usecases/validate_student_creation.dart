import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class ValidateStudentCreation
    implements Usecase<bool, ValidateStudentCreationParams> {
  final AuthRepository authRepository;

  ValidateStudentCreation(this.authRepository);

  @override
  Future<Either<Failure, bool>> call(
      ValidateStudentCreationParams params) async {
    // Get current user to validate parent context
    final currentUserResult = await authRepository.getCurrentUser();

    return currentUserResult.fold(
      (failure) => Left(failure),
      (currentUser) async {
        // Validate parent context
        if (currentUser.uid.isEmpty) {
          return Left(Failure('Invalid parent authentication'));
        }

        // Validate required fields
        if (params.firstName.trim().isEmpty || params.lastName.trim().isEmpty) {
          return Left(Failure('Student first name and last name are required'));
        }

        if (params.standard.trim().isEmpty) {
          return Left(Failure('Student standard is required'));
        }

        // Validate standard format
        if (!RegExp(r'^[0-9]{1,2}[a-zA-Z]?$')
            .hasMatch(params.standard.trim())) {
          return Left(
              Failure('Please enter a valid standard (e.g., 1, 12A, 10B)'));
        }

        // Validate subjects
        if (params.subjects.isEmpty) {
          return Left(Failure('At least one subject is required'));
        }

        // All validations passed
        return const Right(true);
      },
    );
  }
}

class ValidateStudentCreationParams {
  final String firstName;
  final String lastName;
  final String standard;
  final List<String> subjects;

  ValidateStudentCreationParams({
    required this.firstName,
    required this.lastName,
    required this.standard,
    required this.subjects,
  });
}
