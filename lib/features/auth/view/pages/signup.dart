// password match add to styled_textField
// Fix spacings
// Fix appBar color tint and remove back arrow

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jop_finder_app/core/utils/app_router.dart';
import 'package:jop_finder_app/features/auth/view/pages/signin.dart';
import 'package:jop_finder_app/features/auth/view/pages/shared/styled_Button.dart';
import 'package:jop_finder_app/features/auth/view/pages/shared/styled_textField.dart';
import 'package:jop_finder_app/features/auth/view/pages/shared/text_Divider.dart';
import 'package:jop_finder_app/features/auth/view/pages/shared/welcome_text.dart';
import 'package:jop_finder_app/features/auth/viewmodel/cubit/auth_cubit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //Key for validation
  final _formKey = GlobalKey<FormState>();

  // Create controllers for the TextFields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  //Register button onpressed
  bool registerCheck() {
    //condition to check the validation of textfields
    if (_formKey.currentState!.validate()) {
      //check if password and confirmpassword match
      if (_confirmPasswordController.text == _passwordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password doesn't match"),
          ),
        );
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 253),
        appBar: AppBar(),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is AuthError) {
                    return Center(
                      child: Text(state.errorMessage),
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //First three Rows of Text presentation of the title headline and text
                        const WelcomeText(
                            title: "Jôbizz",
                            headline: "Registration 👍",
                            text: "Let’s Register. Apply to jobs!"),
                        const SizedBox(height: 30),

                        //TextFileds for name email password and confirm pass
                        StyledTextField(
                            hint: "Full Name",
                            icon: Icons.person_outlined,
                            controller: _fullNameController),
                        const SizedBox(height: 16),
                        StyledTextField(
                            hint: "E-mail",
                            icon: Icons.mail_outline_outlined,
                            controller: _emailController),
                        const SizedBox(height: 16),
                        StyledTextField(
                            hint: "Password",
                            icon: Icons.lock_outlined,
                            isPassword: true,
                            controller: _passwordController),
                        const SizedBox(height: 16),
                        StyledTextField(
                            hint: "Confirm Password",
                            icon: Icons.lock_outlined,
                            isPassword: true,
                            controller: _confirmPasswordController),
                        const SizedBox(height: 30),

                        //Button to Register
                        StyledButton(
                            onPressed: () {
                              if (registerCheck()) {
                                BlocProvider.of<AuthCubit>(context).signUp(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    context: context);
                              }
                            },
                            text: "Register"),
                        const SizedBox(height: 30),

                        //Text between two lines
                        const TextBetweenDivider(text: "Or continue with"),
                        const SizedBox(height: 20),

                        //Row for the Google and facebook Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(),
                            SvgPicture.asset(
                              'assets/images/google.svg',
                              width: 30,
                              height: 30,
                            ),
                            const Icon(
                              Icons.facebook,
                              color: Colors.blue,
                              size: 38,
                            ),
                            const SizedBox(),
                          ],
                        ),
                        const SizedBox(height: 50),

                        //Row with Text and TextButton for navigation to Login screen
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Text(
                                "Have an account?",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 175, 176, 182),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to login screen
                                GoRouter.of(context)
                                    .pushReplacementNamed(AppRouter.login);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 53, 104, 153),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
