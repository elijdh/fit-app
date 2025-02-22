import 'package:fitapp/components/pagecomponents.dart';
import 'package:fitapp/firestore/exercisesdb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:fitapp/util/create_exercise_widget.dart';
import 'package:fitapp/database/exercise.dart';
import 'package:fitapp/components/theme/color_lib.dart';
import 'package:fitapp/firestore/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class Exercises extends StatefulWidget {
  const Exercises({super.key});

  @override
  State<Exercises> createState() => _ExercisesState();
}

enum ExerciseOrder { alphabetical, databaseOrder }

class _ExercisesState extends State<Exercises> {
  AuthService authService = AuthService();
  User? user = FirebaseAuth.instance.currentUser;
  Future<List<Exercise>>? futureExercises;
  final exerciseDB = ExercisesDB();
  final FocusNode _searchFocusNode = FocusNode();
  List<Exercise> allExercises = [];
  List<Exercise> filteredExercises = [];
  ExerciseOrder selectedOrder = ExerciseOrder.alphabetical;
  String accountType = "";

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
    fetchExercises();
    _checkAccountType();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkAccountType() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userID = user?.uid;
    Map<String, dynamic>? userData = await authService.getDataByUUID(userID!);
    setState(() {
      accountType = userData?['accountType'];
    });
    Provider.of<AuthNotifier>(context, listen: false).setLoggedIn(user != null);
  }

  void _onSearchFocusChange() {
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
              color: Colors.transparent.withOpacity(0.4),
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
            searchResult: Container(),
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
                padding: const EdgeInsets.only(top: 10, left: 25.0, right: 25.0),
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
                                            if (accountType == 'admin') {
                                              await exerciseDB.deleteExercise(
                                                  exercise.id);
                                            }
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
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              CreateExerciseWidget(
                                                exercise: exercise,
                                                onSubmit: (name) async {
                                                  await exerciseDB.updateExercises(
                                                    exercise.id,name,name
                                                  );
                                                  fetchExercises();
                                                },
                                              ),
                                        );
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: DefBlur(
                      sigmaX: 50,
                      sigmaY: 50,
                      child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        child: const Icon(Icons.add),
                        onPressed: () {
                          (accountType == "admin" || accountType == "premium") ?
                          showDialog(
                            context: context,
                            builder: (_) =>
                                CreateExerciseWidget(
                                  onSubmit:  (name) async {
                                    if (accountType == "premium") {
                                      await exerciseDB.newUserExercise(name, name); // Assuming name is used twice intentionally
                                    } else {
                                      await exerciseDB.newExercise(name, name); // Assuming name is used twice intentionally
                                    }

                                    if (!mounted) return;
                                    fetchExercises();
                                  },
                                ),
                          ) :
                            showDialog(
                              context: context,
                                builder: (_) =>
                                  ConfirmationDialog(
                                      title: "Create an Exercise",
                                      message: "If you want to create a custom exercise, you need to subscribe to Ascendo+",
                                      onConfirm: (){
                                        Navigator.of(context, rootNavigator: true).pop();
                                      }
                                  )
                            );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
