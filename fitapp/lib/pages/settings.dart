import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/firestore/auth_methods.dart';
import 'package:fitapp/pages/subpages/settings/login_page.dart';
import 'package:fitapp/pages/subpages/settings/signup_page.dart';
import 'package:fitapp/pages/subpages/settings/change_password.dart';
import 'package:fitapp/pages/subpages/settings/logout.dart';
import 'package:fitapp/pages/subpages/settings/user_appearance.dart';
import 'package:flutter/material.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/pages/subpages/fitness/workoutnow.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  AuthService authService = AuthService();

  @override
  void initState(){
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    User? user = FirebaseAuth.instance.currentUser;
    Provider.of<AuthNotifier>(context, listen: false).setLoggedIn(user != null);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        return DefBackground(
          body: SafeArea(
            child: Format(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageTitle(text: 'Settings'),
                  ],
                ),
                const Subtitle(text: 'Account'),
                authNotifier.loggedIn ?
                const StackedButtons(
                    titles: ["Account Details", "Password & Security", "Payment Methods", "Logout"],
                    routes: [WorkoutNow(), PasswordPage(), WorkoutNow(), Logout()]) :
                const StackedButtons(
                    titles: ["Register", "Login"],
                    routes: [SignupPage(), LoginPage()]),
                const Subtitle(text: 'Subscription'),
                const DefButton(
                  route: WorkoutNow(),
                  title: "Dynamic Name that indicates users Subscription",
                ),
                const Subtitle(text: 'Personalize'),
                const DefButton(
                  route: UserAppearance(),
                  title: "Theme & Appearance",
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      }
    );
  }
}
