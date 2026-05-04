// ============================================================
// LEVEL 4: USECASE TESTS WITH MOCKING
// ============================================================
// Here's where it gets interesting. Your use cases depend on
// repositories — but we DON'T want to hit Supabase in tests.
// So we create a MOCK: a fake version that we control.
//
// 🧠 KEY CONCEPTS:
//
// MOCK = A fake object that pretends to be the real thing.
//        You tell it "when someone calls loginWithEmailAndPassword,
//        return THIS result". It never touches Supabase.
//
// WHY? Because unit tests must be:
//   - Fast (no network calls)
//   - Reliable (no "Supabase is down" failures)
//   - Isolated (testing ONLY the use case, not the DB)
//
// PACKAGE: We use 'mocktail' — you just extend Mock and
//          implement the interface. That's it.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

// Your project imports
import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_login.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_signup.dart';

// ════════════════════════════════════════════════════════════
//  STEP 1: Create the mock class
// ════════════════════════════════════════════════════════════
// This creates a fake AuthRepository. Mocktail generates all
// the methods for you — you just extend Mock + implement your
// interface.
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  // The things we need in our tests
  late MockAuthRepository mockAuthRepository;
  late UserLogin userLogin;
  late UserSignup userSignup;

  // A reusable test user
  final testUser = User(
    uid: 'test-uid-123',
    email: 'test@example.com',
    firstName: 'John',
    middleName: 'M',
    lastName: 'Doe',
    emailVerified: true,
    userType: Usertype.parent,
  );

  setUp(() {
    // Fresh mock + fresh use case for each test
    mockAuthRepository = MockAuthRepository();
    userLogin = UserLogin(mockAuthRepository);
    userSignup = UserSignup(mockAuthRepository);
  });

  // ════════════════════════════════════════════════════════════
  //  UserLogin Tests
  // ════════════════════════════════════════════════════════════
  group('UserLogin', () {
    final loginParams = UserLoginParams(
      email: 'test@example.com',
      password: 'password123',
    );

    test('returns User on successful login', () async {
      // ARRANGE:
      // Tell the mock: "When someone calls loginWithEmailAndPassword
      // with ANY email and password, return Right(testUser)"
      //
      // when() sets up the expectation
      // .thenAnswer() provides the return value
      // any(named: 'email') matches any value for that parameter
      when(() => mockAuthRepository.loginWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(testUser));

      // ACT: call the use case
      final result = await userLogin(loginParams);

      // ASSERT: check the result
      // result.isRight() means success (Right side of Either)
      expect(result.isRight(), true);

      // Extract the actual value from Right
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (user) {
          expect(user.email, 'test@example.com');
          expect(user.firstName, 'John');
          expect(user.userType, Usertype.parent);
        },
      );

      // VERIFY: make sure the repository was actually called
      // This catches bugs where the use case forgets to call the repo
      verify(() => mockAuthRepository.loginWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).called(1); // Called exactly once
    });

    test('returns Failure when login fails', () async {
      // ARRANGE: This time, make the mock return a failure
      when(() => mockAuthRepository.loginWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Left(Failure('Invalid credentials')));

      // ACT
      final result = await userLogin(loginParams);

      // ASSERT
      expect(result.isLeft(), true); // Left = failure

      result.fold(
        (failure) => expect(failure.message, 'Invalid credentials'),
        (user) => fail('Expected failure but got user'),
      );
    });

    test('returns Failure on no internet', () async {
      when(() => mockAuthRepository.loginWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Left(Failure('No internet connection')));

      final result = await userLogin(loginParams);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'No internet connection'),
        (_) => fail('Expected failure'),
      );
    });

    test('passes correct parameters to repository', () async {
      when(() => mockAuthRepository.loginWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(testUser));

      await userLogin(UserLoginParams(
        email: 'specific@email.com',
        password: 'specific_password',
      ));

      // Verify the EXACT parameters were passed through
      verify(() => mockAuthRepository.loginWithEmailAndPassword(
            email: 'specific@email.com',
            password: 'specific_password',
          )).called(1);
    });
  });

  // ════════════════════════════════════════════════════════════
  //  UserSignup Tests
  // ════════════════════════════════════════════════════════════
  group('UserSignup', () {
    final signupParams = UserSignupParams(
      firstName: 'Jane',
      middleName: 'A',
      lastName: 'Smith',
      email: 'jane@example.com',
      password: 'secure123',
    );

    test('returns User on successful signup', () async {
      final newUser = User(
        uid: 'new-uid',
        email: 'jane@example.com',
        firstName: 'Jane',
        middleName: 'A',
        lastName: 'Smith',
        emailVerified: false, // Not verified yet after signup
        userType: Usertype.none, // No type selected yet
      );

      when(() => mockAuthRepository.signInWithEmailAndPassword(
            firstName: any(named: 'firstName'),
            middleName: any(named: 'middleName'),
            lastName: any(named: 'lastName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(newUser));

      final result = await userSignup(signupParams);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected success'),
        (user) {
          expect(user.emailVerified, false);
          expect(user.userType, Usertype.none);
          expect(user.firstName, 'Jane');
        },
      );
    });

    test('returns Failure when email already exists', () async {
      when(() => mockAuthRepository.signInWithEmailAndPassword(
            firstName: any(named: 'firstName'),
            middleName: any(named: 'middleName'),
            lastName: any(named: 'lastName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
              (_) async => Left(Failure('User with this email already exists')));

      final result = await userSignup(signupParams);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('already exists')),
        (_) => fail('Expected failure'),
      );
    });
  });
}
