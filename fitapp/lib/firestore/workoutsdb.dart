import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/database/exercise.dart';
import 'package:fitapp/database/workout.dart';
import 'package:fitapp/firestore/auth_methods.dart';

class WorkoutsDB {

  // Assuming FirebaseAuth.instance.currentUser is of type User?
  User? user = FirebaseAuth.instance.currentUser;
  AuthService authService = AuthService();

  Future<void> newWorkout(String name, String? description, String scheduled, List<String> exerciseIds, String userUid) async {
    CollectionReference workouts = FirebaseFirestore.instance.collection(
        'workouts');
    Map<String, dynamic>? userData = await authService.getDataByUUID(userUid!);
    String uuid = '';
    if (userData?['accountType'] == 'admin'){
      uuid = 'default';
    } else {
      uuid = userUid;
    }

    return workouts.add({
      'name': name,
      'description': description,
      'exerciseIds': exerciseIds,
      'scheduled': scheduled,
      'userUid': uuid,

    })
        .then((value) => print("Workout added successfully!"))
        .catchError((error) => print("Failed to add workout: $error"));
  }

  Future<List<Workout>> fetchWorkoutForUser(String? userUid) async {
    CollectionReference workouts = FirebaseFirestore.instance.collection('workouts');

    try {
      QuerySnapshot snapshot = await workouts.where('userUid', whereIn: [userUid ?? 'default', 'default']).get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      List<Workout> workoutsData = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Ensure exerciseIds is cast to List<String>
        List<String> exerciseIds = List<String>.from(data['exerciseIds'] ?? []);
        return Workout(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          exerciseIds: exerciseIds,
          scheduled: data['scheduled'] ?? '',
          userUid: data['userUid'] ?? 'default',
        );
      }).toList();

      return workoutsData;
    } catch (error) {
      print("Failed to fetch workouts: $error");
      return []; // Return empty list in case of failure
    }
  }

  Future<List<Workout>> fetchDefaultWorkouts() async {
    CollectionReference workouts = FirebaseFirestore.instance.collection('workouts');

    try {
      QuerySnapshot snapshot;
        snapshot = await workouts.where('userUid', isEqualTo: 'default').get();

      if (snapshot.docs.isEmpty) {
        return []; // Return empty list if no documents are found
      }

      List<Workout> workoutsData = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Ensure exerciseIds is cast to List<String>
        List<String> exerciseIds = List<String>.from(data['exerciseIds'] ?? []);
        return Workout(
          id: doc.id,
          name: data['name'] ?? '', // Provide default value in case of null
          description: data['description'] ?? '', // Provide default value in case of null
          exerciseIds: exerciseIds,
          scheduled: data['scheduled'] ?? '', // Provide default value in case of null
          userUid: data['userUid'] ?? 'default', // Ensure userUid is assigned
        );
      }).toList();

      return workoutsData;
    } catch (error) {
      print("Failed to fetch workouts: $error");
      return []; // Return empty list in case of failure
    }
  }

  Future<List<Workout>> fetchWorkouts() async {
    CollectionReference workouts = FirebaseFirestore.instance.collection('workouts');

    try {
      QuerySnapshot snapshot = await workouts.get();

      if (snapshot.docs.isEmpty) {
        return []; // Return empty list if no documents are found
      }


      // If user is null, assign a default string
      String userString = user != null ? user.toString() : "default";

      List<Workout> workoutsData = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Ensure exerciseIds is cast to List<String>
        List<String> exerciseIds = List<String>.from(data['exerciseIds'] ?? []);
        return Workout(
          id: doc.id,
          name: data['name'] ?? '', // Provide default value in case of null
          description: data['description'] ?? '', // Provide default value in case of null
          exerciseIds: exerciseIds,
          scheduled: data['scheduled'] ?? '', // Provide default value in case of null
          userUid: userString
        );
      }).toList();

      return workoutsData;
    } catch (error) {
      print("Failed to fetch workouts: $error");
      return []; // Return empty list in case of failure
    }
  }

  Future<Workout?> fetchWorkoutById(String workoutId) async {
    CollectionReference workouts = FirebaseFirestore.instance.collection('workouts');

    try {
      DocumentSnapshot snapshot = await workouts.doc(workoutId).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Fetch referenced exercises
        List<String> exerciseIds = (data['exerciseIds'] as List<dynamic>).map((id) => id.toString()).toList();

        // If user is null, assign a default string
        String userString = user != null ? user.toString() : "default";

        // Construct the Workout object
        return Workout(
          id: snapshot.id,
          name: data['name'],
          description: data['description'],
          exerciseIds: exerciseIds, // Updated to use the converted exerciseIds
          scheduled: data['scheduled'],
          userUid: userString
        );
      } else {
        print('No workout found with ID: $workoutId');
        return null;
      }
    } catch (error) {
      print("Failed to fetch workout: $error");
      return null;
    }
  }

  Future<void> changeWorkoutName(String workoutId, String newName) async {
    CollectionReference workouts = FirebaseFirestore.instance.collection('workouts');
    Workout? workout = await fetchWorkoutById(workoutId);
    if (workout == null){
      return;
    }
    return workouts.doc(workoutId).update({
      "name" : newName})
        .then((value) => print("Workout name changed successfully!"))
        .catchError((error) => print("Failed to change workout name: $error"));;
  }

  Future<void> changeWorkoutDescription(String workoutId, String newDesc) async {
    CollectionReference workouts = FirebaseFirestore.instance.collection('workouts');
    Workout? workout = await fetchWorkoutById(workoutId);
    if (workout == null){
      return;
    }
    return workouts.doc(workoutId).update({
      "description" : newDesc})
        .then((value) => print("Workout description changed successfully!"))
        .catchError((error) => print("Failed to change workout description: $error"));;
  }

  Future<void> deleteExerciseFromWorkout(String workoutId, String exerciseId) async {
    CollectionReference workouts = FirebaseFirestore.instance.collection('workouts');
    Workout? workout = await fetchWorkoutById(workoutId);
    if (workout == null){
      return;
    }
    return workouts.doc(workoutId).update({
      "exerciseIds" : FieldValue.arrayRemove([exerciseId])})
        .then((value) => print("Exercise removed successfully from workout!"))
        .catchError((error) => print("Failed to remove exercise: $error"));;
  }

  Future<void> deleteWorkouts(String workoutId) {
    CollectionReference workouts = FirebaseFirestore.instance.collection(
        'workouts');

    return workouts.doc(workoutId).delete()
        .then((value) => print("Workout deleted successfully!"))
        .catchError((error) => print("Failed to delete workout: $error"));
  }
}