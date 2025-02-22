import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/database/freestyle.dart';
import 'package:fitapp/firestore/exercisesdb.dart';
import 'package:fitapp/firestore/freestyledb.dart';
import 'package:flutter/material.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:fitapp/util/create_exercise_widget.dart';
import 'package:fitapp/database/exercise.dart';

class FreestylePage extends StatefulWidget {
  const FreestylePage({Key? key}) : super(key: key);

  @override
  State<FreestylePage> createState() => _FreestyleState();
}

class _FreestyleState extends State<FreestylePage> {
  final freestyleDB = FreestyleDB();
  final exerciseDB = ExercisesDB();
  int itemCounter = 0;
  List<int> setCounter = [];
  List<Exercise?> exerciseList = [];
  late String freestyleId;
  late bool freestyleActive;
  late Freestyle? activeWorkout;

  @override
  void initState() {
    super.initState();
    setCounter.add(1);
    _checkActiveWorkout();
  }

  Future<void> _checkActiveWorkout() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? uuid = user?.uid;
    late bool proceed;
    freestyleActive = await freestyleDB.hasActiveFreestyle(uuid!);
    if (freestyleActive) {
      activeWorkout = await freestyleDB.fetchActiveFreestyle(uuid);
      print("The active workout is: $activeWorkout");
      await ConfirmationDialog( // Use 'await' to wait for the dialog result
        title: "You have an active workout!",
        message: "Would you like to continue with your workout?",
        cancelBtnText: "New",
        confirmBtnText: "Continue",
        onCancel: () {
          setState(() {
            proceed = false;
            freestyleDB.changeActiveStatus(activeWorkout!.id);
            freestyleActive = false;
            activeWorkout = null;
          });
          Navigator.of(context, rootNavigator: true).pop();
        },
        onConfirm: () async {
          proceed = true;
          _loadActiveWorkout();
          Navigator.of(context, rootNavigator: true).pop();
        },
      ).show(context); // Call show to display the dialog
    } else {
      activeWorkout = null;
    }
  }

  void _loadActiveWorkout() async {
    if (activeWorkout != null) {
      print(activeWorkout!.exerciseIds);
      List<Exercise?> exercises = await exerciseDB.fetchById(activeWorkout!.exerciseIds);
      setState(() {
        exerciseList = exercises;
        itemCounter = exercises.length;
        setCounter = List.generate(exerciseList.length, (_) => 1);
        for (var i = 0; i < exerciseList.length; i++) {
          final exerciseId = exerciseList[i]!.id;
          for (var exercise in activeWorkout!.exercises) {
            if (exercise['exerciseId'] == exerciseId) {
              setCounter[i] = exercise['sets'].length + 1;
              break;
            }
          }
        }
        freestyleId = activeWorkout!.id;
      });
    }
  }

  void createFreestyle(String exerciseId) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userString = user?.uid;

    // Await the newFreestyle function outside of setState
    freestyleId = await freestyleDB.newFreestyle(
        "Freestyle 1",
        [exerciseId],
        [{'sets': []}],
        "testdate",
        userString,
        5.5
    );

    // Then, update the state
    setState(() {});
  }

  void addExercise(String exerciseId) async {
    freestyleDB.addExercise(freestyleId, exerciseId);
    setState(() {
      setCounter.add(1); // Add a new set counter when a new exercise is added
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefBackground(
      body: SuperScaffold(
        stretch: false,
        appBar: SuperAppBar(
          backgroundColor: Colors.transparent,
          previousPageTitle: "",
          leading: const DefBackButton(),
          actions: IconButton(
            onPressed: () {
            },
            icon: const Icon(
                Icons.history,
                color: Colors.white),
          ),
          title: Text(
            "Freestyle",
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
            largeTitle: "Freestyle",
          ),
        ),
        body: SafeArea(
          top: false,
          child: CarouselSlider.builder(
            itemCount: itemCounter + 1,
            options: CarouselOptions(
              aspectRatio: 0.75,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              initialPage: 0,
              autoPlay: false,
            ),
            itemBuilder: (context, index, realIndex) {
              return index == (itemCounter)
              ? Card(
                color: Colors.black.withOpacity(0.5),
                  child: SizedBox(
                      width: 600,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final selectedExercise = await showDialog<Exercise>(
                              context: context,
                              builder: (_) => const FreestyleExerciseList(),
                            );
                            if (selectedExercise != null) {
                              setState(() {
                                exerciseList.add(selectedExercise);
                                itemCounter++;
                              });
                            }
                            if (index == 0){
                              createFreestyle(selectedExercise!.id);
                            } else {
                              addExercise(selectedExercise!.id);
                            }
                          },
                        )
                      )
                  )
              ): Card(
                color: Colors.transparent.withOpacity(0.5),
                child: Container(
                  color: Colors.transparent,
                  width: 600,
                    padding: const EdgeInsets.all(25),
                    child: Center(
                    child:
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                exerciseList[index]!.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: context.theme.appColors.onSurface,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  setState(() {
                                    exerciseList.removeAt(index);
                                    freestyleDB.removeExercise(freestyleId, index);
                                    setCounter.removeAt(index);
                                    itemCounter--;
                                  });
                                },
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: setCounter.isNotEmpty ? setCounter[index] : 1,
                              itemBuilder: (context, index){
                                if (index == 0) {
                                  // return the header
                                  return const ListTile(
                                    visualDensity: VisualDensity(vertical: -4),
                                    onTap: null,
                                    title: Center(
                                        child: Text(
                                          "Set",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    )),
                                    trailing: SizedBox(
                                      width: 100,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                SizedBox(
                                                  width: 45,
                                                  child: Text(
                                                      "Reps",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                SizedBox(
                                                  width: 45,
                                                  child: Text(
                                                    "Weight",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                index -= 1;

                                return ListTile(
                                  visualDensity: VisualDensity(vertical: -3),
                                  title: Center(
                                    child: Text(
                                      "${index+1}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  trailing: SizedBox(
                                    width: 100,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            decoration: null,
                                            controller: TextEditingController(),
                                            enabled: true,
                                            onChanged: (value) {
                                              // Assuming your TextEditingControllers are properly set up
                                              freestyleDB.updateSet(
                                                freestyleId,
                                                itemCounter,
                                                index,
                                                reps: int.tryParse(value) ?? 0, // Assuming you want reps as an integer
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 40,
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            decoration: null,
                                            controller: TextEditingController(),
                                            enabled: true,
                                            onChanged: (value) {
                                              freestyleDB.updateSet(
                                                freestyleId,
                                                itemCounter,
                                                index,
                                                weight: double.tryParse(value) ?? 0.0,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: IconButton(
                                  onPressed: setCounter[index] == 1 ? null : () {
                                    setState(() {
                                    setCounter[index]--;
                                    freestyleDB.removeSet(freestyleId, itemCounter);
                                  });},
                                  icon: Icon(
                                      Icons.remove,
                                   color: setCounter == 0 ? Colors.grey.shade800 : Colors.white),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                    setCounter[index]++;
                                    freestyleDB.addSet(freestyleId, itemCounter);
                                  });},
                                  icon: const Icon(
                                      Icons.add,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  )
                ),
              );
            },
          
          ),
        ),
      ),
    );
  }
}

class FreestyleExerciseList extends StatefulWidget {
  const FreestyleExerciseList({Key? key}) : super(key: key);

  @override
  State<FreestyleExerciseList> createState() => _FreestyleExerciseListState();
}

enum ExerciseOrder { alphabetical, databaseOrder }

class _FreestyleExerciseListState extends State<FreestyleExerciseList> {
  Future<List<Exercise>>? futureExercises;
  final exerciseDB = ExercisesDB();
  final FocusNode _searchFocusNode = FocusNode();
  List<Exercise> allExercises = [];
  List<Exercise> filteredExercises = [];
  ExerciseOrder selectedOrder = ExerciseOrder.alphabetical;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
    fetchExercises();
  }

  @override
  void dispose() {
    // Dispose of the FocusNode to avoid memory leaks
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    // If search bar loses focus (likely due to cancel action), reset searchQuery
    if (!_searchFocusNode.hasFocus) {
      setState(() {
        searchQuery = "";
        filteredExercises = allExercises;
      });
    }
  }

  void fetchExercises() {
    setState(() {
      futureExercises = exerciseDB.fetchExercises().then((exercises) {
        allExercises = exercises;
        print("All Exercises: $allExercises");
        return exercises;
      });
    });
  }

  void filterExercises(String query) {
    print("Query: $query");
    setState(() {
      filteredExercises = allExercises
          .where((exercise) =>
          exercise.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      print("Filtered Exercises: $filteredExercises");
    });
  }

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return DefBackground(
      body: SuperScaffold(
        stretch: false,
        appBar: SuperAppBar(
          actions: SuperAction(
            child: PopupMenuButton<ExerciseOrder>(
              icon: const Icon(Icons.sort),
              color: Colors.black.withOpacity(0.7),
              onSelected: (ExerciseOrder result) {
                setState(() {
                  selectedOrder = result;
                  fetchExercises();
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<ExerciseOrder>>[
                const PopupMenuItem<ExerciseOrder>(
                  value: ExerciseOrder.alphabetical,
                  child: Text('Alphabetical'),
                ),
                const PopupMenuItem<ExerciseOrder>(
                  value: ExerciseOrder.databaseOrder,
                  child: Text('Order Created'),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          leading: const DefBackButton(),
          previousPageTitle: "",
          title: Text("Exercises",
              style: TextStyle(
                  color: context.theme.appColors.onSurface)),
          searchBar: SuperSearchBar(
            resultColor: Colors.transparent,
            cancelTextStyle:
            TextStyle(color: context.theme.appColors.onSurface),
            enabled: true,
            resultBehavior: SearchBarResultBehavior.visibleOnInput,
            onChanged: (query) {
              setState(() {
                searchQuery = query;
                if (query.isEmpty) {
                  // If the query is empty, reset the list
                  searchQuery = '';
                  filteredExercises = allExercises;
                } else {
                  // If there is something in the query, filter the exercises
                  filterExercises(query);
                }
                print("Search bar changed: $query");
              });
            },
            onSubmitted: (query) {
              // Handle submission of the search bar
              print("Search bar submitted: $query");
              if (query.isEmpty) {
                // If the submitted query is empty, reset the list
                setState(() {
                  searchQuery = "";
                  filteredExercises = allExercises;
                });
              }
            },
            searchResult: Container(color: Colors.transparent),
            searchFocusNode: _searchFocusNode,
          ),
          largeTitle: SuperLargeTitle(
            enabled: true,
            largeTitle: "Exercises",
            height: 45,
          ),
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 25.0, right: 25.0),
                child: SlidableAutoCloseBehavior(
                  closeWhenTapped: true,
                  closeWhenOpened: true,
                  child: FutureBuilder<List<Exercise>>(
                    future: futureExercises,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      } else {
                        final exercises = filteredExercises.isNotEmpty
                            ? filteredExercises
                            : allExercises;
                        return allExercises.isEmpty
                            ? const Center(
                          child: Text(
                            'No Exercises...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ):
                        searchQuery.isNotEmpty && filteredExercises.isEmpty
                            ? const Center(
                          child: Text(
                            'No Search Results',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        )
                            : ListView.separated(
                          padding: const EdgeInsets.only(top: 0),
                          separatorBuilder: (context, index) =>
                              Divider(
                                height: 0,
                                thickness: 0.75,
                                color: context.theme
                                    .appColors.onSecondaryContainer,
                              ),
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            var sortedExercises =
                            allExercises.toList();
                            if (selectedOrder ==
                                ExerciseOrder.alphabetical) {
                              sortedExercises.sort((a, b) =>
                                  a.name.compareTo(b.name));
                            }
                            final exercise =
                            sortedExercises[index];
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
                              child: DefBlur(
                                child: Container(
                                  color: Colors.black.withOpacity(0.4),
                                  child: Slidable(
                                    endActionPane: ActionPane(
                                      extentRatio: 0.25,
                                      motion: const DrawerMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) async {
                                            await exerciseDB
                                                .deleteExercise(exercise.id);
                                            fetchExercises();
                                          },
                                          backgroundColor: Colors.red,
                                          icon: Icons.delete,
                                        )
                                      ],
                                    ),
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
                                      title: Text(
                                        exercise.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      onTap: () {
                                        // Pass the selected exercise back to the Freestyle widget
                                        Navigator.pop(context, exercise);
                                      },
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
              Positioned(
                bottom: 16.0, // Adjust the top value as needed
                right: 16.0, // Adjust the right value as needed
                child: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CreateExerciseWidget(
                        onSubmit: (name) async {
                          await exerciseDB.newExercise(name, name);
                          if (!mounted) return;
                          fetchExercises();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

