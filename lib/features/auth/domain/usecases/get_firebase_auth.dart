import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

class GetFirebaseAuth implements Usecase<FirebaseAuth, NoParams> {
  final AuthRepository repository;

  GetFirebaseAuth(this.repository);

  @override
  Future<Either<Failure,FirebaseAuth>> call(NoParams params) async {
    return await repository.getFirebaseAuth();
  }
}