import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitapp/database/workout.dart';
import 'package:fitapp/firestore/exercisesdb.dart';
import 'package:fitapp/firestore/workoutsdb.dart';
import 'package:flutter/material.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:fitapp/database/exercise.dart';

class CreateWorkoutTwo extends StatefulWidget {
  final ScrollController controller;
  final Function()? onDonePressed;

  const CreateWorkoutTwo({
    Key? key,
    required this.controller,
    this.onDonePressed,
  }) : super(key: key);

  @override
  State<CreateWorkoutTwo> createState() => _CreateWorkoutState(controller: controller);
}

class _CreateWorkoutState extends State<CreateWorkoutTwo> {
  Future<List<String>>? futureExerciseIds;
  Future<List<Exercise>>? futureExercises;

  Future<List<Workout>>? futureWorkouts;
  final exerciseDB = ExercisesDB();
  final workoutDB = WorkoutsDB();
  final ScrollController controller;

  _CreateWorkoutState({
    required this.controller,
  });

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Track the selected exercise IDs
  Set<String> selectedExerciseIds = {};

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  void fetchExercises() {
    setState(() {
      futureExerciseIds = exerciseDB.fetchExerciseIds();
      futureExercises = exerciseDB.fetchExercises();
    });
  }

  void selectExercise(String exerciseId) {
    setState(() {
      if (selectedExerciseIds.contains(exerciseId)) {
        selectedExerciseIds.remove(exerciseId);
      } else {
        selectedExerciseIds.add(exerciseId);

      }
    });
  }

  void fetchWorkouts() {
    setState(() {
      futureWorkouts = workoutDB.fetchWorkouts();
    });
  }


  void createWorkoutTable() async {
    // Handle Done logic when exercises are selected
    if (selectedExerciseIds.isNotEmpty) {
      final workoutName = nameController.text;
      final workoutDescription = descriptionController.text;
      User? user = FirebaseAuth.instance.currentUser;

      String? userString = user?.uid;

      // Create the workout in the workout table
      workoutDB.newWorkout(
        workoutName,
        workoutDescription,
        "testdate",
        selectedExerciseIds.toList(),
        userString!
      );

      // Optionally, you can navigate to another screen or perform any other actions
      nameController.clear();
      descriptionController.clear();
      fetchWorkouts();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please select exercises for the workout!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
    selectedExerciseIds.clear(); // Clear selected exercises
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.appColors.primary,
      body: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: TextButton(
                                onPressed: nameController.text.isNotEmpty && selectedExerciseIds.isNotEmpty
                                    ? () {
                                  if (widget.onDonePressed != null){
                                    widget.onDonePressed!();
                                  }
                                  createWorkoutTable();
                                }
                                    : null, // Call the method to create a workout table
                                child: Text(
                                  nameController.text.isEmpty && selectedExerciseIds.isNotEmpty ? "Done" : "Done",
                                  style: TextStyle(color: context.theme.appColors.onSurface),
                                ),
                              ),
                            ),
                            const Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Create New Workout",
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  RoundedTextField(
                    controller: nameController,
                    hintText: 'Name',
                    enabled: selectedExerciseIds.isEmpty,
                  ),
                  const SizedBox(height: 12),
                  RoundedTextField(
                    controller: descriptionController,
                    hintText: 'Description',
                    enabled: selectedExerciseIds.isEmpty,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Exercise>>(
                    future: futureExercises,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        final exercises = snapshot.data!;
                        exercises.sort((a, b) => a.name.compareTo(b.name));

                        return exercises.isEmpty
                            ? const Center(
                          child: Text(
                            'No Exercises',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        )
                            : Expanded(
                          child: ListView.separated(
                            controller: controller,
                            padding: const EdgeInsets.only(top: 0),
                            separatorBuilder: (context, index) =>
                                Divider(
                                  height: 0,
                                  thickness: 0.75,
                                  color: context.theme.appColors.tertiaryContainer,
                                ),
                            itemCount: exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = exercises[index];

                              return ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: index == 0
                                      ? const Radius.circular(12)
                                      : Radius.zero,
                                  topRight: index == 0
                                      ? const Radius.circular(12)
                                      : Radius.zero,
                                  bottomLeft: index == exercises.length - 1
                                      ? const Radius.circular(12)
                                      : Radius.zero,
                                  bottomRight:
                                  index == exercises.length - 1
                                      ? const Radius.circular(12)
                                      : Radius.zero,
                                ),
                                child: Container(
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: index == 0
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                        topRight: index == 0
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                        bottomLeft:
                                        index == exercises.length - 1
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                        bottomRight:
                                        index == exercises.length - 1
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                      ),
                                    ),
                                    tileColor: context.theme.appColors.surfaceVariant.withOpacity(0.5),
                                    title: Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () async {
                                        // Toggle edit mode for the selected exercise
                                        selectExercise(exercise.id);
                                        print('Selected Exercises: $selectedExerciseIds');
                                      },
                                      icon: Icon(
                                        selectedExerciseIds.contains(exercise.id)
                                            ? Icons.check
                                            : Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoundedTextField extends StatelessWidget {
  const RoundedTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.onChanged,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final Function(String)? onChanged;


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.theme.appColors.primary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
        enabled: enabled,
        onChanged: onChanged,
      ),
    );
  }
}