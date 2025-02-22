import 'package:fitapp/pages/subpages/fitness/workouts.dart';
import 'package:flutter/material.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/pages/subpages/fitness/exercises.dart';
import 'package:fitapp/pages/subpages/fitness/freestylepage.dart';
import 'package:fitapp/pages/subpages/fitness/workoutnow.dart';
import 'package:fitapp/pages/subpages/fitness/workouts.dart';
import 'package:fitapp/components/pagecomponents.dart';

class Fitness extends StatefulWidget {
  const Fitness({super.key});

  @override
  State<Fitness> createState() => _FitnessState();
}

class _FitnessState extends State<Fitness> {
  @override
  Widget build(BuildContext context) {
    return const DefBackground(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Format(
          children: [
            PageTitle(text: 'Fitness'),
            Subtitle(text: 'Workout'),
            StackedButtons(
                titles: ["Workout Now", "Freestyle Workout"],
                routes: [WorkoutNow(), FreestylePage()]),
            Subtitle(text: 'Exercise Lists'),
            StackedButtons(
                titles: ["Workouts", "Exercises"],
                routes: [Workouts(), Exercises()]),
          ],
        ),
      ),
    );
  }
}
