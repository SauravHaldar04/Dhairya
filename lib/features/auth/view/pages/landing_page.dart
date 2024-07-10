import 'package:aparna_education/core/theme/app_pallete.dart';
import 'package:aparna_education/features/auth/view/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(0),
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text(
                      "Welcome!",
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          color: Pallete.primaryColor),
                    ),
                    Text(
                      "Teaching has never been any easier! ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                Image(
                  image: AssetImage("assets/images/Illustration.png"),
                  fit: BoxFit.fitWidth,
                ),
                Column(
                  children: [
                    AuthButton(
                      text: 'Sign Up',
                      onPressed: () {},
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    AuthButton(
                      text: 'Log In',
                      onPressed: () {},
                      isInverted: true,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
