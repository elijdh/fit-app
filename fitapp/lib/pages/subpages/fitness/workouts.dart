import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/firestore/exercisesdb.dart';
import 'package:fitapp/firestore/workoutsdb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/database/workout.dart';
import 'package:fitapp/util/create_workout_widget_two.dart';
import 'package:fitapp/util/testappbar.dart';
import 'package:super_cupertino_navigation_bar/models/super_appbar.model.dart';
import 'package:super_cupertino_navigation_bar/models/super_large_title.model.dart';
import 'package:super_cupertino_navigation_bar/models/super_search_bar.model.dart';
import '../../../database/exercise.dart';

class Workouts extends StatefulWidget {
  const Workouts({Key? key}) : super(key: key);

  @override
  State<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends State<Workouts> {
  Future<List<Workout>>? futureWorkouts;
  final workoutDB = WorkoutsDB();
  final upperScrollController = ScrollController();
  final lowerScrollController = ScrollController();
  final panelScrollController = ScrollController();
  final panelController = PanelController();
  Workout? selectedWorkout;

  void revertToCreateWorkout() {
    setState(() {
      selectedWorkout = null;
    });
  }

  @override
  void initState() {
    super.initState();

    fetchWorkouts();
  }

  void fetchWorkouts() {
    User? user = FirebaseAuth.instance.currentUser;
    // If user is null, assign a default string
    String? uuid = user?.uid;
    setState(() {
      print(workoutDB);
      if (uuid != null) {
        futureWorkouts = workoutDB.fetchWorkoutForUser(uuid!);
      } else {
        futureWorkouts = workoutDB.fetchDefaultWorkouts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefBackground(
      body: EliteScaffold(
        stretch: false,
        appBar: SuperAppBar(
          actions: IconButton(
            onPressed: () {
              panelController.isPanelOpen?
              panelController.close():panelController.open();
              setState(() {
                selectedWorkout = null;
              });
            },
            icon: const Icon(
                Icons.add,
                color: Colors.white),
          ),
          leading: const DefBackButton(),
          backgroundColor: Colors.transparent,
          previousPageTitle: "",
          title: Text(
            "Workouts",
            style: TextStyle(color: context.theme.appColors.onSurface),
          ),
          searchBar: SuperSearchBar(
            enabled: false,
          ),
          largeTitle: SuperLargeTitle(
            enabled: true,
            largeTitle: "Workouts",
            height: 45,
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: SlidingUpPanel(
            controller: panelController,
            minHeight: 185,
            maxHeight: 750,
            snapPoint: 0.5,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            panel: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: selectedWorkout != null
                  ? FutureBuilder<Workout?>(
                future: workoutDB.fetchWorkoutById(selectedWorkout!.id), // Fetch exercises for the selected workout
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const Center(
                      child: Text(
                        'Error loading exercises.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    );
                  } else {
                    final exercises = snapshot.data!;
                    return WorkoutDetails(
                      workout: selectedWorkout!,
                      onDonePressed: () {
                        setState(() {
                          selectedWorkout = null;
                        });
                        panelController.close();
                        fetchWorkouts();
                      },
                    );
                  }
                },
              )
                  : CreateWorkoutTwo(
                  controller: lowerScrollController,
                  onDonePressed: () {
                    panelController.close();
                    fetchWorkouts();
                  },
              ),
            ),
            body: Stack(
              children: [
                SlidableAutoCloseBehavior(
                  closeWhenTapped: true,
                  closeWhenOpened: true,
                  child: Container(
                    padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
                    height: 550,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        children: [
                          Expanded(
                            child: FutureBuilder<List<Workout>>(
                              future: futureWorkouts,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError || snapshot.data == null) {
                                  return const Center(
                                    child: Text(
                                      'Error loading workouts.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                      ),
                                    ),
                                  );
                                } else {
                                  final workouts = snapshot.data!;
                                  return workouts.isEmpty
                                      ? const Center(
                                    child: Text(
                                      'No Workouts...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                      ),
                                    ),
                                  )
                                      : NotificationListener<ScrollNotification>(
                                    onNotification: (notification) {
                                      if (notification is ScrollUpdateNotification) {
                                        if (notification.metrics.pixels < 0) {
                                          panelScrollController.animateTo(
                                            panelScrollController.offset + notification.scrollDelta!,
                                            duration: Duration(milliseconds: 0),
                                            curve: Curves.linear,
                                          );
                                        }
                                      }
                                      return false; // Allow event to propagate further
                                    },
                                    child: ListView.separated(
                                      controller: upperScrollController,
                                      padding: const EdgeInsets.only(top: 0),
                                      separatorBuilder: (context, index) => Divider(
                                        height: 0,
                                        thickness: 0.75,
                                        color: context.theme.appColors.tertiaryContainer,
                                      ),
                                      itemCount: workouts.length,
                                      itemBuilder: (context, index) {
                                        final workout = workouts[index];
                                        return ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: index == 0 ? const Radius.circular(12) : Radius.zero,
                                            topRight: index == 0 ? const Radius.circular(12) : Radius.zero,
                                            bottomLeft:
                                            index == workouts.length - 1 ? const Radius.circular(12) : Radius.zero,
                                            bottomRight:
                                            index == workouts.length - 1 ? const Radius.circular(12) : Radius.zero,
                                          ),
                                          child: DefBlur(
                                            child: Container(
                                              color: Colors.black.withOpacity(0.5),
                                              child: Slidable(
                                                endActionPane: ActionPane(
                                                  extentRatio: 0.25,
                                                  motion: const DrawerMotion(),
                                                  children: [
                                                    SlidableAction(
                                                      onPressed: (context) async {
                                                        await workoutDB.deleteWorkouts(workout.id);
                                                        fetchWorkouts();
                                                      },
                                                      backgroundColor: Colors.red,
                                                      icon: Icons.delete,
                                                    )
                                                  ],
                                                ),
                                                child: ListTile(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: index == 0 ? const Radius.circular(12) : Radius.zero,
                                                      topRight: index == 0 ? const Radius.circular(12) : Radius.zero,
                                                      bottomLeft:
                                                      index == workouts.length - 1 ? const Radius.circular(12) : Radius.zero,
                                                      bottomRight:
                                                      index == workouts.length - 1 ? const Radius.circular(12) : Radius.zero,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    workout.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    workout.description ?? '',
                                                    style: TextStyle(color: context.theme.appColors.onSurface),
                                                  ),
                                                  onTap: () {
                                                    panelController.isPanelOpen?
                                                    panelController.close():panelController.animatePanelToPosition(0.5);
                                                    setState(() {
                                                      selectedWorkout = workout;
                                                    });
                                                  },
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WorkoutDetails extends StatefulWidget {
  final Workout workout;
  final Function()? onDonePressed;
  WorkoutDetails({Key? key, required this.workout, this.onDonePressed})
      : super(key: key);

  @override
  _WorkoutDetailsState createState() => _WorkoutDetailsState(workout: workout, onDonePressed: onDonePressed);
}

class _WorkoutDetailsState extends State<WorkoutDetails> {
  final Workout workout;
  final Function()? onDonePressed;

  _WorkoutDetailsState(
      {required this.workout, this.onDonePressed});

  final exerciseDB = ExercisesDB();
  final workoutDB = WorkoutsDB();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Timer? _nameDebounce;
  Timer? _descriptionDebounce;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.workout.name;
    _descriptionController.text = widget.workout.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameDebounce?.cancel();
    _descriptionDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Selected Workout: ${workout.name}");
    print("Number of Exercises: ${workout.exerciseIds.length}"); // Use exerciseIds here

    return Scaffold(
      backgroundColor: context.theme.appColors.primary,
      body: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0),
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
                                onPressed: onDonePressed,
                                child: Text(
                                  'Done',
                                  style: TextStyle(
                                      color: context.theme.appColors.onSurface),
                                ),
                              ),
                            ),
                            const Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Workout Details',
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
                    controller: _nameController,
                    hintText: 'Name',
                    enabled: true,
                    onChanged: (newName) {
                      if (_nameDebounce?.isActive ?? false) _nameDebounce?.cancel();
                      _nameDebounce = Timer(const Duration(milliseconds: 50), () async {
                        await workoutDB.changeWorkoutName(widget.workout.id, newName);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  RoundedTextField(
                    controller: _descriptionController,
                    hintText: 'Description',
                    enabled: true,
                    onChanged: (newDesc) {
                      if (_descriptionDebounce?.isActive ?? false) _descriptionDebounce?.cancel();
                      _descriptionDebounce = Timer(const Duration(milliseconds: 500), () async {
                        await workoutDB.changeWorkoutDescription(widget.workout.id, newDesc);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SlidableAutoCloseBehavior(
                      closeWhenTapped: true,
                      closeWhenOpened: true,
                      child: FutureBuilder<List<Exercise?>>(
                        future: exerciseDB.fetchById(workout.exerciseIds),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                'Error loading exercises.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),
                            );
                          } else {
                            final exercises = snapshot.data ?? [];
                            return ListView.separated(
                              padding: const EdgeInsets.only(top: 0),
                              separatorBuilder: (context, index) =>
                                  Divider(
                                    height: 0,
                                    thickness: 0.75,
                                    color: context.theme.appColors
                                        .tertiaryContainer,
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
                                    bottomLeft:
                                    index == exercises.length - 1
                                        ? const Radius.circular(12)
                                        : Radius.zero,
                                    bottomRight:
                                    index == exercises.length - 1
                                        ? const Radius.circular(12)
                                        : Radius.zero,
                                  ),
                                  child: Slidable(
                                    endActionPane: ActionPane(
                                      extentRatio: 0.25,
                                      motion: const DrawerMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) async {
                                            workoutDB.deleteExerciseFromWorkout(workout.id, exercise!.id);
                                          },
                                          backgroundColor: Colors.red,
                                          icon: Icons.delete,
                                        )
                                      ],
                                    ),
                                    child: ListTile(
                                      tileColor: context.theme.appColors
                                          .surfaceVariant.withOpacity(0.5),
                                      title: Text(
                                        exercise!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
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