import 'package:aparna_education/app_bootstrap.dart';
import 'package:aparna_education/core/cubits/auth_user/auth_user_cubit.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aparna_education/features/lectures/presentation/bloc/lectures_bloc.dart';
import 'package:aparna_education/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:aparna_education/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:aparna_education/features/teachers/teacher_interest/presentation/bloc/teacher_interest_bloc.dart';
import 'package:aparna_education/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppProviders {
  static Future<void> run(Widget app) async {
    await AppBootstrap.initialize();

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
          BlocProvider<NotificationsBloc>(
            create: (context) => serviceLocator<NotificationsBloc>(),
          ),
          BlocProvider<TeacherInterestBloc>(
            create: (context) => serviceLocator<TeacherInterestBloc>(),
          ),
        ],
        child: app,
      ),
    );
  }
}
