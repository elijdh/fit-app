import 'dart:ui';

import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/firestore/auth_methods.dart';
import 'package:fitapp/util/testappbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:super_cupertino_navigation_bar/models/super_appbar.model.dart';
import 'package:super_cupertino_navigation_bar/models/super_appbar_bottom.model.dart';
import 'package:super_cupertino_navigation_bar/models/super_large_title.model.dart';
import 'package:super_cupertino_navigation_bar/models/super_search_bar.model.dart';

class Logout extends StatefulWidget {
  const Logout({Key? key}) : super(key: key);

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Provider.of<AuthNotifier>(context, listen: false).setLoggedIn(false);
    Navigator.pop(context);
  }

  Future<Dialog> _showConfirmationDialog() async {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.transparent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Logout Confirmation',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                SizedBox(height: 20),
                const Text("Are you sure you want to logout?"),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(), // Use rootNavigator
                      child: const Text('Cancel', style: TextStyle(color: Colors.white),),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        _signOut();
                      },
                      child: const Text('Logout', style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return DefBackground(
      body: EliteScaffold(
        appBar: SuperAppBar(
          backgroundColor: Colors.transparent,
          leading: const DefBackButton(),
          title: Text(
            "Logout",
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
            largeTitle: "Logout",
          ),
        ),
        body: Format(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent.withOpacity(0.5),
                  ),
                  onPressed: () async {
                    Dialog dialog = await _showConfirmationDialog(); // Store the result
                    await showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => dialog,
                    );
                  },
                  child: const Text("Logout"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}



