import 'package:aparna_education/core/theme/app_theme.dart';
import 'package:aparna_education/core/widgets/app_loading.dart';
import 'package:aparna_education/core/utils/snackbar.dart';
import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:aparna_education/features/auth/presentation/pages/verification_page.dart';
import 'package:aparna_education/features/auth/presentation/widgets/auth_button.dart';
import 'package:aparna_education/features/auth/presentation/widgets/auth_textfield.dart';
import 'package:aparna_education/features/home/presentation/pages/parent_layout_page.dart';
import 'package:aparna_education/features/home/presentation/pages/teacher_layout_page.dart';
import 'package:aparna_education/features/home/presentation/pages/language_learner_layout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _routeUser(BuildContext context, dynamic state) {
    if (state.user.emailVerified) {
      Widget destination;
      switch (state.user.userType) {
        case Usertype.parent:
          destination = const ParentLayoutPage();
          break;
        case Usertype.teacher:
          destination = const TeacherLayoutPage();
          break;
        case Usertype.languageLearner:
          destination = const LanguageLearnerLayoutPage();
          break;
        default:
          destination = const VerificationPage();
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const VerificationPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              showSnackbar(context, 'Login Successful');
              _routeUser(context, state);
              // After navigation, dispatch AuthIsUserLoggedIn to update app state
              Future.microtask(() {
                if (mounted) {
                  context.read<AuthBloc>().add(AuthIsUserLoggedIn());
                }
              });
            }
            if (state is AuthFailure) {
              showSnackbar(context, state.message);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Back button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      PhosphorIconsRegular.arrowLeft,
                      color: colorScheme.onSurface,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header
                  Text(
                    'Welcome\nBack',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your journey.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Form
                  if (state is AuthLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: AppLoading(),
                    )
                  else ...[
                    AuthTextfield(
                      controller: emailController,
                      text: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: PhosphorIconsRegular.envelope,
                    ),
                    const SizedBox(height: 16),
                    AuthTextfield(
                      controller: passwordController,
                      text: 'Password',
                      isPassword: true,
                      prefixIcon: PhosphorIconsRegular.lock,
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Login button
                  AuthButton(
                    text: 'Log In',
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogIn(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          ));
                    },
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: colorScheme.outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: colorScheme.outline)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Google sign-in
                  AuthButton(
                    text: 'Continue with Google',
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthGoogleSignIn());
                    },
                    isInverted: true,
                  ),

                  const SizedBox(height: 24),

                  // Terms
                  Text.rich(
                    TextSpan(
                      text: 'By continuing you agree to the ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
