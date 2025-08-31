import 'package:aparna_education/core/cubits/auth_user/auth_user_cubit.dart';
import 'package:aparna_education/core/network/check_internet_connection.dart';
import 'package:aparna_education/features/auth/data/datasources/auth_remote_datasources.dart';
import 'package:aparna_education/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';
import 'package:aparna_education/core/usecase/current_user.dart';
import 'package:aparna_education/features/auth/domain/usecases/get_current_user_id.dart';
import 'package:aparna_education/features/auth/domain/usecases/is_user_email_verified.dart';
import 'package:aparna_education/features/auth/domain/usecases/update_email_verification.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_login.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_signup.dart';
import 'package:aparna_education/features/auth/domain/usecases/verify_user_email.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aparna_education/features/profile/data/datasources/language_learner_remote_datasource.dart';
import 'package:aparna_education/features/profile/data/datasources/parent_remote_datasource.dart';
import 'package:aparna_education/features/profile/data/datasources/teacher_remote_datasorce.dart';
import 'package:aparna_education/features/profile/data/datasources/student_remote_datasource.dart';
import 'package:aparna_education/features/profile/data/repositories/language_learner_repository_impl.dart';
import 'package:aparna_education/features/profile/data/repositories/parent_repository_impl.dart';
import 'package:aparna_education/features/profile/data/repositories/teacher_repository_impl.dart';
import 'package:aparna_education/features/profile/data/repositories/student_repository_impl.dart';
import 'package:aparna_education/features/profile/domain/repositories/language_learner_repository.dart';
import 'package:aparna_education/features/profile/domain/repositories/parent_repository.dart';
import 'package:aparna_education/features/profile/domain/repositories/teacher_repository.dart';
import 'package:aparna_education/features/profile/domain/repositories/student_repository.dart';
import 'package:aparna_education/features/profile/domain/usecases/add_language_learner.dart';
import 'package:aparna_education/features/profile/domain/usecases/add_parent.dart';
import 'package:aparna_education/features/profile/domain/usecases/update_parent.dart';
import 'package:aparna_education/features/profile/domain/usecases/add_teacher.dart';
import 'package:aparna_education/features/profile/domain/usecases/add_student.dart';
import 'package:aparna_education/features/profile/domain/usecases/get_parent.dart';
import 'package:aparna_education/features/profile/domain/usecases/get_students_by_parent.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/core/secrets/secrets.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;
Future<void> initDependencies() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseAnonKey,
  );
  
  _initAuth();
  _initProfile();

  final SupabaseClient supabaseClient = Supabase.instance.client;
  final Logger logger = Logger();
  
  serviceLocator.registerSingleton<SupabaseClient>(supabaseClient);
  serviceLocator.registerSingleton<Logger>(logger);
  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerFactory<CheckInternetConnection>(
      () => CheckInternetConnectionImpl(
            serviceLocator(),
          ));
  serviceLocator.registerLazySingleton(() => AuthUserCubit());
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSources>(
      () => AuthRemoteDataSourcesImpl(
        serviceLocator<SupabaseClient>(),
      ),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserSignup(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    // ..registerFactory(
    //   () => GoogleLogin(
    //     serviceLocator(),
    //   ),
    // )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => VerifyUserEmail(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => IsUserEmailVerified(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateEmailVerification(
        serviceLocator(),
      ),
    )
    // ..registerFactory(
    //   () => GetFirebaseAuth(
    //     serviceLocator(),
    //   ),
    // )
    ..registerFactory(
      () => GetCurrentUserId(
        serviceLocator(),
      ),
    )
    ..registerFactory(() => AuthBloc(
          updateEmailVerification: serviceLocator(),
          logger: serviceLocator(),
          userSignup: serviceLocator(),
          userLogin: serviceLocator(),
          currentUser: serviceLocator(),
          //googleSignIn: serviceLocator(),
          verifyUserEmail: serviceLocator(),
         // getFirebaseAuth: serviceLocator(),
          isUserEmailVerified: serviceLocator(),
        ));
}

void _initProfile() {
  serviceLocator
    ..registerFactory<TeacherRemoteDatasource>(
      () => TeacherRemoteDatasorceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<TeacherRepository>(
      () => TeacherRepositoryImpl(
        serviceLocator(),
        teacherRemoteDatasource: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AddTeacher(
        serviceLocator(),
      ),
    )
    ..registerFactory<ParentRemoteDatasource>(
      () => ParentRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<ParentRepository>(
      () => ParentRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AddParent(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateParent(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetParent(
        serviceLocator(),
      ),
    )
    ..registerFactory<LanguageLearnerRemoteDatasource>(
      () => LanguageLearnerRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<LanguageLearnerRepository>(
      () => LanguageLearnerRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AddLanguageLearner(
        serviceLocator(),
      ),
    )
    ..registerFactory<StudentRemoteDatasource>(
      () => StudentRemoteDatasourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<StudentRepository>(
      () => StudentRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AddStudent(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetStudentsByParent(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ProfileBloc(
        getStudentsByParent: serviceLocator(),
        addStudent: serviceLocator(),
        getParent: serviceLocator(),
        addParent: serviceLocator(),
        updateParent: serviceLocator(),
        addTeacher: serviceLocator(),
        getCurrentUser: serviceLocator(),
        addLanguageLearner: serviceLocator(),
      ),
    );
}
