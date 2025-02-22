import 'package:flutter/material.dart';
import 'package:fitapp/components/theme/color_lib.dart';

class ExerciseTile extends StatelessWidget {

  final icon;
  final String exerciseName;
  final String exerciseDesc;
  final color;

  const ExerciseTile({
    Key? key,
    required this.icon,
    required this.exerciseName,
    required this.exerciseDesc,
    required this.color,
  }) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.appColors.onInverseSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: color,
                    child: Icon(icon),
                  ),
                ),
                const SizedBox(
                  width:8,
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(
                        exerciseName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        exerciseDesc,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ]),
              ],
            ),
            const Icon(Icons.more_horiz),
          ],
        ),
      ),
    );
  }
}
