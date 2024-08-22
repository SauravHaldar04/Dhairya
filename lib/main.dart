import 'package:aparna_education/core/cubits/auth_user/auth_user_cubit.dart';
import 'package:aparna_education/core/theme/theme.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aparna_education/features/profile/presentation/pages/profile_selection_page.dart';
import 'package:aparna_education/features/auth/presentation/pages/landing_page.dart';
import 'package:aparna_education/features/auth/presentation/pages/verification_page.dart';
import 'package:aparna_education/firebase_options.dart';
import 'package:aparna_education/init_dependencies.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (context) => serviceLocator<AuthUserCubit>()),
      BlocProvider(create: (context) => serviceLocator<AuthBloc>()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
    context.read<AuthBloc>().add(AuthIsUserEmailVerified());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aparna Education',
      theme: AppTheme.appTheme,
      home: BlocSelector<AuthBloc, AuthState, bool>(
        selector: (state) {
          return state is AuthUserLoggedIn;
        },
        builder: (context, state) {
          if (state) {
            return BlocSelector<AuthBloc, AuthState, bool>(
              selector: (state) {
                return state is AuthEmailVerified;
              },
              builder: (context, state) {
                if (state) return const HomePage();
                return const VerificationPage();
              },
            );
          }
          return const LandingPage();
        },
      ),
    );
  }
}