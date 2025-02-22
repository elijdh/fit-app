import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:fitapp/firestore/auth_methods.dart';
import 'package:fitapp/pages/subpages/settings/signup_page.dart';
import 'package:fitapp/util/testappbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

TextEditingController usernameController = new TextEditingController();
TextEditingController passwordController = new TextEditingController();
String email = "";
String? errorText;


class _LoginPageState extends State<LoginPage> {
  AuthService authService = AuthService();


  void login() async{
    if (!isValidEmail(usernameController.text)){
      Map<String, dynamic>? userData = await authService.getDataByUsername(usernameController.text);
      setState(() {
        email = userData?['email'];
      });
    } else {
      email = usernameController.text;
    }
    if (usernameController.text != null && passwordController.text != null) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: passwordController.text
        );
        setState(() {
          errorText = null;
          usernameController.text = "";
          passwordController.text = "";
        });
        Provider.of<AuthNotifier>(context, listen: false).setLoggedIn(true);
        Navigator.pop(context);
      } catch (e) {
        print(e);
        setState(() {
          errorText = "Sorry, your username and/or password are invalid.";
        });
      }
    }
  }

  bool isValidEmail(String email) {
    String emailRegex =
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool didPop) {
        if (didPop){
          usernameController.clear();
          passwordController.clear();
        }
      },
      child: DefBackground(
        body: EliteScaffold(
          appBar: SuperAppBar(
            backgroundColor: Colors.transparent,
            leading: const DefBackButton(),
            title: Text(
              "Login",
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
              largeTitle: "Login",
            ),
          ),
          body: Format(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 300,
                  ),
                   FormContainerWidget(
                    controller: usernameController,
                    hintText: "Username or Email",
                    isPasswordField: false,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FormContainerWidget(
                    controller: passwordController,
                    hintText: "Password",
                    isPasswordField: true,
                    errorText: errorText,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent.withOpacity(0.5),
                    ),
                    onPressed: () {
                      login();
                      // Use username and password for signup
                    },
                    child: Text("LOGIN"),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: const TextButton(
                        onPressed: null,
                        child: Text("Forgot Password")
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account yet?",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              CupertinoPageRoute<Widget>(
                                builder: (context) {
                                  return const SignupPage();
                                },
                              ),
                            ),
                          child: const Text("Register",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),),),
                      ],
                    ),
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
