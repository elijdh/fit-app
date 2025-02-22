import 'package:flutter/material.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/pages/subpages/fitness/exercises.dart';
import 'package:fitapp/pages/subpages/fitness/freestylepage.dart';
import 'package:fitapp/pages/subpages/fitness/workoutnow.dart';
import 'package:fitapp/pages/subpages/fitness/workouts.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/components/theme/color_lib.dart';

class Nutrition extends StatefulWidget {
  const Nutrition({super.key});

  @override
  State<Nutrition> createState() => _NutritionState();
}

class _NutritionState extends State<Nutrition> {
  @override
  Widget build(BuildContext context) {
    return const DefBackground(
      body: SafeArea(
        child: Format(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageTitle(text: 'Nutrition'),
                Icon(Icons.more_horiz),
              ],
            ),
            SizedBox(height: 15),
            DefButton(
              route: WorkoutNow(),
              title: "Workout Now",
            ),
            DefButton(
              route: FreestylePage(),
              title: "Freestyle Workout",
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageTitle(text: 'Something Else Nutrition'),
                Icon(Icons.more_horiz),
              ],
            ),
            SizedBox(height: 15),
            DefButton(
              route: Workouts(),
              title: "Workouts",
            ),
            DefButton(
              route: Exercises(),
              title: "Exercises",
            ),
          ],
        ),
      ),
    );
  }
}
