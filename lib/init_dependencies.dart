import 'package:aparna_education/core/cubits/auth_user/auth_user_cubit.dart';
import 'package:aparna_education/core/network/check_internet_connection.dart';
import 'package:aparna_education/core/services/fcm_service.dart';
import 'package:aparna_education/features/lectures/data/datasources/lectures_remote_datasource.dart';
import 'package:aparna_education/features/lectures/data/repositories/lectures_repository_impl.dart';
import 'package:aparna_education/features/lectures/domain/repositories/lectures_repository.dart';
import 'package:aparna_education/features/lectures/domain/usecases/get_templates.dart';
import 'package:aparna_education/features/lectures/domain/usecases/update_template.dart';
import 'package:aparna_education/features/lectures/domain/usecases/delete_template.dart';
import 'package:aparna_education/features/lectures/domain/usecases/materialize_lecture.dart';
import 'package:aparna_education/features/lectures/domain/usecases/schedule_lecture_notification.dart';
import 'package:aparna_education/features/lectures/domain/usecases/get_lecture_notifications.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:aparna_education/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:aparna_education/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:aparna_education/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:aparna_education/features/notifications/domain/repositories/notification_repository.dart';
import 'package:aparna_education/features/notifications/domain/usecases/get_cached_notifications.dart';
import 'package:aparna_education/features/notifications/domain/usecases/get_notifications.dart';
import 'package:aparna_education/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:aparna_education/features/teachers/teacher_interest/data/datasources/teacher_interest_remote_datasource.dart';
import 'package:aparna_education/features/teachers/teacher_interest/data/repositories/teacher_interest_repository_impl.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/repositories/teacher_interest_repository.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/usecases/get_pending_interests.dart';
import 'package:aparna_education/features/teachers/teacher_interest/domain/usecases/update_interest_status.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_bloc.dart';
import 'package:aparna_education/features/auth/data/datasources/auth_remote_datasources.dart';
import 'package:aparna_education/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aparna_education/features/auth/domain/repository/auth_repository.dart';
import 'package:aparna_education/core/usecase/current_user.dart';
import 'package:aparna_education/features/auth/domain/usecases/get_current_user_id.dart';
import 'package:aparna_education/features/auth/domain/usecases/google_login.dart';
import 'package:aparna_education/features/auth/domain/usecases/is_user_email_verified.dart';
import 'package:aparna_education/features/auth/domain/usecases/update_email_verification.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_login.dart';
import 'package:aparna_education/features/auth/domain/usecases/user_signup.dart';
import 'package:aparna_education/features/auth/domain/usecases/verify_user_email.dart';
import 'package:aparna_education/features/auth/domain/usecases/logout_user.dart';
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
import 'package:aparna_education/features/profile/domain/usecases/get_teacher.dart';
import 'package:aparna_education/features/profile/domain/usecases/update_teacher.dart';
import 'package:aparna_education/features/profile/domain/usecases/update_student.dart';
import 'package:aparna_education/features/profile/domain/usecases/get_students_by_parent.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/core/secrets/secrets.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

final serviceLocator = GetIt.instance;
Future<void> initDependencies() async {
  // Initialize local cache storage
  try {
    await Hive.initFlutter();
  } catch (e) {
    print('❌ Failed to initialize local cache: $e');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseAnonKey,
  );
  
  _initAuth();
  _initProfile();
  _initLectures();
  _initNotifications();
  _initTeacherInterest();

  final SupabaseClient supabaseClient = Supabase.instance.client;
  final Logger logger = Logger();
  
  serviceLocator.registerSingleton<SupabaseClient>(supabaseClient);
  serviceLocator.registerSingleton<Logger>(logger);
  serviceLocator.registerLazySingleton<FCMService>(
    () => FCMService(serviceLocator<SupabaseClient>()),
  );
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
    ..registerFactory(
      () => GoogleLogin(
        serviceLocator(),
      ),
    )
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
    ..registerFactory(
      () => LogoutUser(
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
          googleSignIn: serviceLocator(),
          verifyUserEmail: serviceLocator(),
         // getFirebaseAuth: serviceLocator(),
          isUserEmailVerified: serviceLocator(),
      logoutUser: serviceLocator(),
      fcmService: serviceLocator(),
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
    ..registerFactory(
      () => GetTeacher(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateTeacher(
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
      () => UpdateStudent(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ProfileBloc(
        getStudentsByParent: serviceLocator(),
        addStudent: serviceLocator(),
        updateStudent: serviceLocator(),
        getParent: serviceLocator(),
        getTeacher: serviceLocator(),
        updateTeacher: serviceLocator(),
        addParent: serviceLocator(),
        updateParent: serviceLocator(),
        addTeacher: serviceLocator(),
        getCurrentUser: serviceLocator(),
        addLanguageLearner: serviceLocator(),
      ),
    );
}

void _initNotifications() {
  serviceLocator
    ..registerFactory<NotificationLocalDataSource>(
      () => NotificationLocalDataSourceImpl(),
    )
    ..registerFactory<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<NotificationRepository>(
      () => NotificationRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetCachedNotifications(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetNotifications(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => MarkNotificationRead(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => NotificationsBloc(
        getCachedNotifications: serviceLocator(),
        getNotifications: serviceLocator(),
        markNotificationRead: serviceLocator(),
      ),
    );
}

void _initTeacherInterest() {
  serviceLocator
    ..registerFactory<TeacherInterestRemoteDataSource>(
      () => TeacherInterestRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<TeacherInterestRepository>(
      () => TeacherInterestRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetPendingInterests(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateInterestStatus(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => TeacherInterestBloc(
        getPendingInterests: serviceLocator(),
        updateInterestStatus: serviceLocator(),
      ),
    );
}

void _initLectures() {
  serviceLocator
    ..registerFactory<LecturesRemoteDataSource>(
      () => LecturesRemoteDataSourceImpl(
        serviceLocator<SupabaseClient>(),
      ),
    )
    ..registerFactory<LecturesRepository>(
      () => LecturesRepositoryImpl(
         serviceLocator(),
         serviceLocator(),
      ),
    )
    // Use Cases - Template Management
    ..registerFactory(
      () => GetTemplates(serviceLocator()),
    )
    ..registerFactory(
      () => UpdateTemplate(serviceLocator()),
    )
    ..registerFactory(
      () => DeleteTemplate(serviceLocator()),
    )
    ..registerFactory(
      () => MaterializeLecture(serviceLocator()),
    )
    // Use Cases - Notifications
    ..registerFactory(
      () => ScheduleLectureNotification(serviceLocator()),
    )
    ..registerFactory(
      () => GetLectureNotifications(serviceLocator()),
    )
    // BLoC
    ..registerLazySingleton(
      () => LecturesBloc(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    );
}
