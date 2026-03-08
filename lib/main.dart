// main.dart

import 'package:aparna_education/core/cubits/auth_user/auth_user_cubit.dart';
import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/theme/theme.dart';
import 'package:aparna_education/core/utils/loader.dart';
import 'package:aparna_education/core/utils/app_logger.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:aparna_education/features/home/presentation/pages/language_learner_layout_page.dart';
import 'package:aparna_education/features/home/presentation/pages/parent_layout_page.dart';
import 'package:aparna_education/features/home/presentation/pages/teacher_layout_page.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/features/profile/presentation/pages/profile_selection_page.dart';
import 'package:aparna_education/features/auth/presentation/pages/landing_page.dart';
import 'package:aparna_education/features/auth/presentation/pages/verification_page.dart';
import 'package:aparna_education/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aparna_education/core/config/secrets.dart';

/// The main entry point of the Aparna Education application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    print('✅ Environment variables loaded successfully');
    
    // Validate all required secrets are present
    Secrets.validate();
  } catch (e) {
    print('❌ Failed to load environment variables: $e');
    print('Please ensure .env file exists with all required variables');
    // In production, you might want to show an error screen instead of crashing
  }

  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthUserCubit>(
          create: (context) => serviceLocator<AuthUserCubit>(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => serviceLocator<AuthBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => serviceLocator<ProfileBloc>(),
        ),
        BlocProvider<LecturesBloc>(
          create: (context) => serviceLocator<LecturesBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a separate widget to initialize the AuthBloc
    return MaterialApp(
      title: 'Aparna Education',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AppInitializer(),
    );
  }
}

/// A StatefulWidget responsible for initializing authentication status.
class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Dispatch AuthIsUserLoggedIn event once when the app initializes
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          // Display error message using a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Loader();
          } else if (state is AuthUserLoggedIn) {
            final user = state.user;
            if (user.emailVerified) {
              if (user.userType == Usertype.parent) {
                AppLogger.info('👨‍👩‍👧‍👦 User logged in as parent: ${user.email}');
                return const ParentLayoutPage();
              } else if (user.userType == Usertype.teacher) {
                AppLogger.info('👨‍🏫 User logged in as teacher: ${user.email}');
                return const TeacherLayoutPage();
              } else if (user.userType == Usertype.languageLearner) {
                AppLogger.info('🎓 User logged in as language learner: ${user.email}');
                return const LanguageLearnerLayoutPage();
              } else if (user.userType == Usertype.none) {
                AppLogger.info('👤 User needs to select profile type: ${user.email}');
                return const HomePage();
              } else {
                AppLogger.warning('⚠️ Unknown user type for: ${user.email}');
                return const HomePage();
              }
            } else {
              AppLogger.info('📧 User needs email verification: ${user.email}');
              return const VerificationPage();
            }
          } else {
            AppLogger.info('🚪 User is not logged in - showing landing page');
            return const LandingPage();
          }
        },
      ),
    );
  }
}
