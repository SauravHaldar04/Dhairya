// ============================================================
// LEVEL 5: BLOC TESTS (Most advanced)
// ============================================================
// BLoC tests verify: "When I add THIS event to the BLoC,
// it emits THESE states in THIS order."
//
// 🧠 KEY CONCEPTS:
//
// bloc_test package gives you blocTest() — a helper that:
//   1. Creates the BLoC
//   2. Adds an event
//   3. Checks the emitted states match what you expect
//
// The magic: you mock ALL the use cases (the BLoC's dependencies),
// so the BLoC runs its logic but never hits any real service.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';

// Your project imports
import 'package:aparna_education/core/entities/user_entity.dart';
import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/usecase/usecase.dart';
import 'package:aparna_education/core/usecase/current_user.dart';
import 'package:aparna_education/core/services/fcm_service.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_login.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_signup.dart';
import 'package:aparna_education/features/auth/domain/usecases/google_login.dart';
import 'package:aparna_education/features/auth/domain/usecases/verify_user_email.dart';
import 'package:aparna_education/features/auth/domain/usecases/is_user_email_verified.dart';
import 'package:aparna_education/features/auth/domain/usecases/update_email_verification.dart';
import 'package:aparna_education/features/auth/domain/usecases/logout_user.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';

// ════════════════════════════════════════════════════════════
//  STEP 1: Mock ALL dependencies of AuthBloc
// ════════════════════════════════════════════════════════════
class MockUserSignup extends Mock implements UserSignup {}

class MockUserLogin extends Mock implements UserLogin {}

class MockCurrentUser extends Mock implements CurrentUser {}

class MockGoogleLogin extends Mock implements GoogleLogin {}

class MockVerifyUserEmail extends Mock implements VerifyUserEmail {}

class MockIsUserEmailVerified extends Mock implements IsUserEmailVerified {}

class MockUpdateEmailVerification extends Mock
    implements UpdateEmailVerification {}

class MockLogoutUser extends Mock implements LogoutUser {}

class MockFCMService extends Mock implements FCMService {}

// ════════════════════════════════════════════════════════════
//  STEP 2: Create a FAKE Logger (not a Mock)
// ════════════════════════════════════════════════════════════
// Logger has many internal methods that are hard to mock.
// A "Fake" is simpler — it just silently does nothing.
// Use Mock when you need to verify calls.
// Use Fake when you just want the dependency to not crash.
class FakeLogger extends Fake implements Logger {
  @override
  void i(dynamic message,
          {DateTime? time, Object? error, StackTrace? stackTrace}) =>
      {};
  @override
  void e(dynamic message,
          {DateTime? time, Object? error, StackTrace? stackTrace}) =>
      {};
  @override
  void w(dynamic message,
          {DateTime? time, Object? error, StackTrace? stackTrace}) =>
      {};
  @override
  void d(dynamic message,
          {DateTime? time, Object? error, StackTrace? stackTrace}) =>
      {};
  @override
  Future<void> close() async {}
}

void main() {
  // Declare all mocks
  late MockUserSignup mockUserSignup;
  late MockUserLogin mockUserLogin;
  late MockCurrentUser mockCurrentUser;
  late MockGoogleLogin mockGoogleLogin;
  late MockVerifyUserEmail mockVerifyUserEmail;
  late MockIsUserEmailVerified mockIsUserEmailVerified;
  late MockUpdateEmailVerification mockUpdateEmailVerification;
  late MockLogoutUser mockLogoutUser;
  late MockFCMService mockFCMService;
  late FakeLogger fakeLogger;

  // Test data
  final testUser = User(
    uid: 'test-uid',
    email: 'test@example.com',
    firstName: 'John',
    middleName: 'M',
    lastName: 'Doe',
    emailVerified: true,
    userType: Usertype.parent,
  );

  // ════════════════════════════════════════════════════════════
  //  STEP 3: Register fallback values for mocktail
  // ════════════════════════════════════════════════════════════
  // any() needs to know what "default" value to use for each
  // parameter type. This must be done ONCE before all tests.
  setUpAll(() {
    registerFallbackValue(UserLoginParams(email: '', password: ''));
    registerFallbackValue(UserSignupParams(
      firstName: '',
      middleName: '',
      lastName: '',
      email: '',
      password: '',
    ));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    // Fresh mocks for each test
    mockUserSignup = MockUserSignup();
    mockUserLogin = MockUserLogin();
    mockCurrentUser = MockCurrentUser();
    mockGoogleLogin = MockGoogleLogin();
    mockVerifyUserEmail = MockVerifyUserEmail();
    mockIsUserEmailVerified = MockIsUserEmailVerified();
    mockUpdateEmailVerification = MockUpdateEmailVerification();
    mockLogoutUser = MockLogoutUser();
    mockFCMService = MockFCMService();
    fakeLogger = FakeLogger();

    // Default stubs for services that are always called
    when(() => mockFCMService.initialize()).thenAnswer((_) async {});
    when(() => mockFCMService.deactivateToken()).thenAnswer((_) async {});
  });

  // Helper: creates a fresh AuthBloc with all mocks injected
  AuthBloc createBloc() => AuthBloc(
        userSignup: mockUserSignup,
        userLogin: mockUserLogin,
        currentUser: mockCurrentUser,
        googleSignIn: mockGoogleLogin,
        verifyUserEmail: mockVerifyUserEmail,
        isUserEmailVerified: mockIsUserEmailVerified,
        updateEmailVerification: mockUpdateEmailVerification,
        logoutUser: mockLogoutUser,
        fcmService: mockFCMService,
        logger: fakeLogger,
      );

  // ════════════════════════════════════════════════════════════
  //  AuthLogIn Tests
  // ════════════════════════════════════════════════════════════
  group('AuthLogIn', () {
    // blocTest is the key function from bloc_test package.
    // It's a DSL for testing BLoCs:
    //
    //   build:  → creates the BLoC
    //   setUp:  → configures mocks BEFORE the BLoC is built
    //   act:    → adds events to the BLoC
    //   expect: → lists the states that should be emitted (in order)
    //   verify: → runs after test completes (check mock interactions)

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful login',
      // SETUP: configure mock to return success
      setUp: () {
        when(() => mockUserLogin(any()))
            .thenAnswer((_) async => Right(testUser));
      },
      // BUILD: create the BLoC
      build: createBloc,
      // ACT: fire the event
      act: (bloc) => bloc.add(AuthLogIn('test@example.com', 'password123')),
      // EXPECT: these states should be emitted in this exact order
      expect: () => [
        isA<AuthLoading>(), // First: loading starts
        isA<AuthSuccess>(), // Then: success with user
      ],
      // VERIFY: use case was actually called
      verify: (_) {
        verify(() => mockUserLogin(any())).called(1);
        verify(() => mockFCMService.initialize()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on failed login',
      setUp: () {
        when(() => mockUserLogin(any()))
            .thenAnswer((_) async => Left(Failure('Invalid credentials')));
      },
      build: createBloc,
      act: (bloc) => bloc.add(AuthLogIn('bad@email.com', 'wrong')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(), // Failure instead of success
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthFailure contains the correct error message',
      setUp: () {
        when(() => mockUserLogin(any()))
            .thenAnswer((_) async => Left(Failure('No internet connection')));
      },
      build: createBloc,
      act: (bloc) => bloc.add(AuthLogIn('test@example.com', 'pass')),
      expect: () => [
        isA<AuthLoading>(),
        // .having() lets you verify specific properties of emitted states:
        isA<AuthFailure>().having(
          (state) => state.message,
          'error message',
          'No internet connection',
        ),
      ],
    );
  });

  // ════════════════════════════════════════════════════════════
  //  AuthIsUserLoggedIn Tests
  // ════════════════════════════════════════════════════════════
  group('AuthIsUserLoggedIn', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUserLoggedIn] when user is logged in',
      setUp: () {
        when(() => mockCurrentUser(any()))
            .thenAnswer((_) async => Right(testUser));
      },
      build: createBloc,
      act: (bloc) => bloc.add(AuthIsUserLoggedIn()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUserLoggedIn>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when no user is logged in',
      setUp: () {
        when(() => mockCurrentUser(any()))
            .thenAnswer((_) async => Left(Failure('User is not logged in')));
      },
      build: createBloc,
      act: (bloc) => bloc.add(AuthIsUserLoggedIn()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ],
    );
  });

  // ════════════════════════════════════════════════════════════
  //  AuthLogout Tests
  // ════════════════════════════════════════════════════════════
  group('AuthLogout', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthLoggedOut] on successful logout',
      setUp: () {
        when(() => mockLogoutUser(any()))
            .thenAnswer((_) async => const Right(null));
      },
      build: createBloc,
      act: (bloc) => bloc.add(AuthLogout()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthLoggedOut>(),
      ],
      verify: (_) {
        // Verify FCM token was deactivated before logout
        verify(() => mockFCMService.deactivateToken()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when logout throws',
      setUp: () {
        when(() => mockLogoutUser(any())).thenThrow(Exception('Network error'));
      },
      build: createBloc,
      act: (bloc) => bloc.add(AuthLogout()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>(),
      ],
    );
  });

  // ════════════════════════════════════════════════════════════
  //  AuthSignUp Tests
  // ════════════════════════════════════════════════════════════
  group('AuthSignUp', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful signup',
      setUp: () {
        when(() => mockUserSignup(any()))
            .thenAnswer((_) async => Right(testUser));
      },
      build: createBloc,
      act: (bloc) => bloc.add(AuthSignUp(
        'test@example.com',
        'password123',
        'John',
        'Doe',
        'M',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSuccess>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on failed signup',
      setUp: () {
        when(() => mockUserSignup(any()))
            .thenAnswer((_) async => Left(Failure('Email already exists')));
      },
      build: createBloc,
      act: (bloc) => bloc.add(AuthSignUp(
        'existing@example.com',
        'password123',
        'Jane',
        'Doe',
        'A',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthFailure>().having(
          (s) => s.message,
          'message',
          'Email already exists',
        ),
      ],
    );
  });
}
