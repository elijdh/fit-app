import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitapp/components/theme/color_lib.dart';

class WorkoutNow extends StatefulWidget {
  const WorkoutNow({super.key});

  @override
  State<WorkoutNow> createState() => _NutritionState();
}

class _NutritionState extends State<WorkoutNow> {

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: context.theme.appColors.primary,
            border: Border(
              bottom: BorderSide(
                color: brightness == Brightness.dark
                    ? CupertinoColors.black
                    : CupertinoColors.white,
              ),
            ),
            largeTitle: const Text('Workout'),
          ),
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: context.theme.appColors.inverseSurface,
                  ),
                  child: const Text("*map thru users scheduled workouts here*"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}