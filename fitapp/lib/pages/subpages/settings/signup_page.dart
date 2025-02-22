import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:fitapp/firestore/auth_methods.dart';
import 'package:fitapp/util/testappbar.dart';
import 'package:flutter/material.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

TextEditingController usernameController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController confirmPasswordController = TextEditingController();

class _SignupPageState extends State<SignupPage> {
  String? emailErrorText;
  String? passwordErrorText;
  String? confirmPasswordErrorText;
  String? usernameErrorText;
  AuthService authService = AuthService();

  void signUp() async {
    if (!isValidEmail(emailController.text)) {
      setState(() {
        emailErrorText = "Please enter a valid email address";
      });
    } else {
      setState(() {
        emailErrorText = null;
      });
    }

    if (!isValidUser(usernameController.text)) {
      setState(() {
        usernameErrorText = "Invalid characters used in the username. Only alphanumeric characters, period, and underscore are allowed.";
      });
    } else {
      setState(() {
        usernameErrorText = null;
      });
    }

    bool usernameExists = await authService.isUsernameTaken(usernameController.text);
    if(usernameExists){
      setState(() {
        usernameErrorText =
            "Sorry, username is taken!";
      });
    } else {
      setState(() {
        usernameErrorText = null;
      });
    }

    if (!isStrongPassword(passwordController.text)) {
      setState(() {
        passwordErrorText =
        "Password must be at least 8 characters long and contain at least one uppercase letter, one digit, and one special character";
      });
    } else {
      setState(() {
        passwordErrorText = null;
      });
      if (passwordController.text != confirmPasswordController.text){
        setState(() {
          confirmPasswordErrorText =
          "Passwords don't match";
        });
      } else {
        setState(() {
          confirmPasswordErrorText = null;
        });
      }
    }

    if (usernameErrorText == null && emailErrorText == null && passwordErrorText == null && confirmPasswordErrorText == null) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        User? user = FirebaseAuth.instance.currentUser;

        await FirebaseFirestore.instance.collection("users").doc(user?.uid).set({
          "uid": user?.uid,
          "email": emailController.text,
          "username": usernameController.text,
          "password": passwordController.text,
          "accountType": "default",
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent.withOpacity(0.5),
            content: const Text(
                "Your account has been registered! Please check your email for confirmation, then you can login!",
                style: TextStyle(color: Colors.white)
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // show error to user
          setState(() {
            emailErrorText = "Email is already in use";
          });
        }
      }
    }
  }

  bool isValidUser(String username) {
    String userRegex = r'^[a-zA-Z0-9_.]+$';
    RegExp regex = RegExp(userRegex);
    return regex.hasMatch(username);
  }

  bool isValidEmail(String email) {
    String emailRegex =
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }

  bool isStrongPassword(String password) {
    String passwordRegex =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regex = RegExp(passwordRegex);
    return regex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool didPop) {
        if (didPop){
          usernameController.clear();
          passwordController.clear();
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
        }
      },
      child: DefBackground(
        body: EliteScaffold(
          appBar: SuperAppBar(
            backgroundColor: Colors.transparent,
            leading: const DefBackButton(),
            title: Text(
              "Sign Up",
              style: TextStyle(
                color: context.theme.appColors.onSurface,
              ),
            ),
            bottom: SuperAppBarBottom(
              enabled: false,
              height: 0,
            ),
            searchBar: SuperSearchBar(
              enabled: false,
            ),
            largeTitle: SuperLargeTitle(
              enabled: true,
              largeTitle: "Signup",
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 10),
            children: [
              Column(
                children: [
                  const Subtitle(text: 'Personal Information', upperPadding: 0,),
                  const FormContainerWidget(
                    hintText: "First Name",
                    isPasswordField: false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const FormContainerWidget(
                    hintText: "Last Name",
                    isPasswordField: false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const FormContainerWidget(
                    hintText: "Birthday",
                    isPasswordField: false,
                  ),
                  const Subtitle(text: 'Account Details'),
                  FormContainerWidget(
                    controller: usernameController,
                    hintText: "Username",
                    isPasswordField: false,
                    errorText: usernameErrorText,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FormContainerWidget(
                    controller: emailController,
                    hintText: "Email",
                    isPasswordField: false,
                    errorText: emailErrorText,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FormContainerWidget(
                    controller: passwordController,
                    hintText: "Password",
                    isPasswordField: true,
                    errorText: passwordErrorText,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FormContainerWidget(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    isPasswordField: true,
                    errorText: confirmPasswordErrorText,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent.withOpacity(0.5),
                    ),
                    onPressed: () {
                      signUp();

                      // Use username and password for signup
                    },
                    child: const Text("REGISTER"),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
