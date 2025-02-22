import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:fitapp/pages/subpages/settings//signup_page.dart';
import 'package:fitapp/util/testappbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  late TextEditingController oldPasswordController = TextEditingController();
  late TextEditingController newPasswordController = TextEditingController();
  late TextEditingController confirmNewPasswordController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  String? oldPasswordErrorText;
  String? newPasswordErrorText;
  String? confirmPasswordErrorText;

  @override
  void initState() {
    super.initState();
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmNewPasswordController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
}

  void changePassword() async{
    if (!isStrongPassword(newPasswordController.text)) {
      setState(() {
        newPasswordErrorText = "Password must be at least 8 characters long and contain at least one uppercase letter, one digit, and one special character";
      });
      return;
    } else {
      setState(() {
        newPasswordErrorText = null;
      });
    }

    if (currentUser != null && await checkOldPassword(currentUser?.email ?? "", oldPasswordController.text)) {
      setState(() {
        oldPasswordErrorText = "Wrong password";
      });
    }


    if(newPasswordController.text == confirmNewPasswordController.text) {
      try {
        await currentUser?.updatePassword(newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent.withOpacity(0.5),
            content: const Text("Your password has been changed."),
          ),
        );
      } catch (error) {}
    } else {
      setState(() {
        confirmPasswordErrorText =  "Passwords don't match";
      });
    }
  }

  Future<bool> checkOldPassword(String email, String password) async{
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        oldPasswordErrorText = 'Wrong password provided for that user.';
      }
      return false;
    }
  }

  bool isStrongPassword(String password) {
    String passwordRegex =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regex = RegExp(passwordRegex);
    return regex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return DefBackground(
      body: EliteScaffold(
        appBar: SuperAppBar(
          backgroundColor: Colors.transparent,
          leading: Text(""),
          title: Text(
            "Change Password",
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
            largeTitle: "Change Password",
          ),
        ),
        body: Format(
          children: [
            Column(
              children: [
                FormContainerWidget(
                  controller: oldPasswordController,
                  hintText: "Old Password",
                  isPasswordField: true,
                  errorText: oldPasswordErrorText,
                ),
                const SizedBox(
                  height: 20,
                ),
                FormContainerWidget(
                  controller: newPasswordController,
                  hintText: "New Password",
                  isPasswordField: true,
                  errorText: newPasswordErrorText,
                ),
                const SizedBox(
                  height: 20,
                ),
                FormContainerWidget(
                  controller: confirmNewPasswordController,
                  hintText: "Confirm New Password",
                  isPasswordField: true,
                  errorText: confirmPasswordErrorText,

                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent.withOpacity(0.5),
                  ),
                  onPressed: () {
                    changePassword();
                  },
                  child: Text("Change Password"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
