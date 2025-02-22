import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/pages/subpages/fitness/exercises.dart';
import 'package:fitapp/pages/subpages/fitness/workoutnow.dart';
import 'package:fitapp/pages/subpages/fitness/workouts.dart';
import 'package:flutter/material.dart';
import 'package:fitapp/components/theme/color_lib.dart';

class Progress extends StatefulWidget {
  const Progress({super.key});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  @override
  Widget build(BuildContext context) {
    return DefBackground(
      body: SafeArea(
        child: Format(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageTitle(text: 'Progress'),
              ],
            ),
            const Subtitle(text: 'Subscription'),
            const DefButton(
              route: WorkoutNow(),
              title: "Workout Now",
            ),
            const Subtitle(text: 'Personalize'),
            const DefButton(
              route: WorkoutNow(),
              title: "Theme & Appearance",
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise Lists',
                  style: TextStyle(
                    color: context.theme.appColors.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 15),
            const DefButton(
              route: Workouts(),
              title: "Workouts",
            ),
            const DefButton(
              route: Exercises(),
              title: "Exercises",
            ),
          ],
        ),
      ),
    );
  }
}
