import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/core/utils/loader.dart';
import 'package:aparna_education/core/utils/snackbar.dart';
import 'package:aparna_education/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aparna_education/features/profile/presentation/pages/profile_selection_page.dart';
import 'package:aparna_education/features/auth/presentation/pages/verification_page.dart';
import 'package:aparna_education/features/auth/presentation/widgets/auth_button.dart';
import 'package:aparna_education/features/auth/presentation/widgets/auth_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Image(
                            image: AssetImage('assets/images/authBgImage.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      children: [
                        Text(
                          "Welcome Back!",
                          style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w700,
                              color: Pallete.primaryColor),
                        ),
                        Text(
                          "Enter your login details!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                    const Hero(
                      tag: 'illustration',
                      child: SizedBox(
                          height: 250,
                          child: Image(
                            image: AssetImage("assets/images/Illustration.png"),
                            fit: BoxFit.fitHeight,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            showSnackbar(context, "Login Successful");
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                              builder: (context) {
                                context
                                    .read<AuthBloc>()
                                    .add(AuthIsUserEmailVerified());
                                if (state is AuthEmailVerified) {
                                  return const HomePage();
                                }
                                if (state is AuthEmailVerificationFailedState) {
                                  return const VerificationPage();
                                }
                                return const VerificationPage();
                              },
                            ), (route) => false);
                          }
                          if (state is AuthFailure) {
                            showSnackbar(context, state.message);
                          }
                        },
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return const Loader();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AuthTextfield(
                                controller: emailController,
                                text: 'Email',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              AuthTextfield(
                                controller: passwordController,
                                text: 'Password',
                                isPassword: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                      color: Pallete.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Column(
                      children: [
                        AuthButton(
                          text: 'Log In',
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLogIn(
                                emailController.text.trim(),
                                passwordController.text.trim()));
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                              text: "By continuing you are agreeing to the ",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                              children: [
                                TextSpan(
                                    text: "Terms of Service",
                                    style: TextStyle(
                                        color: Pallete.primaryColor,
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: " and ",
                                    style: TextStyle(color: Colors.black)),
                                TextSpan(
                                    text: "Privacy Policy",
                                    style: TextStyle(
                                        color: Pallete.primaryColor,
                                        fontWeight: FontWeight.bold)),
                              ]),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 1,
                              width: 100,
                              color: Colors.grey,
                            ),
                            Text("Or sign in with google"),
                            Container(
                              height: 1,
                              width: 100,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        AuthButton(
                          text: 'Continue with Google',
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthGoogleSignIn());
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Pallete.primaryColor,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
