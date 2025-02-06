// main.dart

import 'package:aparna_education/core/cubits/auth_user/auth_user_cubit.dart';
import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/error/failure.dart';
import 'package:aparna_education/core/theme/theme.dart';
import 'package:aparna_education/core/utils/loader.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';
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
import 'package:logger/logger.dart';

/// The main entry point of the Aparna Education application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: AppTheme.appTheme,
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
            if (state.user.emailVerified) {
              if (state.user.userType == Usertype.parent) {
                print('User is a parent');

                return const ParentLayoutPage();
              } else if (state.user.userType == Usertype.teacher) { 
                print('User is a teacher');

                return const TeacherLayoutPage();
              } else if (state.user.userType == Usertype.languageLearner) {
                print('User is a language learner');
                return const LanguageLearnerLayoutPage();
              } else {
                return const HomePage();
              }
            } else {
              return const VerificationPage();
            }
          } else {
            print('User is not logged in');
            return const LandingPage();
          }
        },
      ),
    );
  }
}
