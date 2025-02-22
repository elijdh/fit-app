import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/database/exercise.dart';

import 'auth_methods.dart';

class ExercisesDB {

  AuthService authService = AuthService();
  User? user = FirebaseAuth.instance.currentUser;


  Future<void> newExercise(String name, String muscleGroup) {
    CollectionReference exercises = FirebaseFirestore.instance.collection(
        'exercises');

    return exercises.add({
      'name': name,
      'muscleGroup': muscleGroup,
    })
        .then((value) => print("Exercise added successfully!"))
        .catchError((error) => print("Failed to add exercise: $error"));
  }



  String generateRandomString(int length) {
    final random = Random();
    const charset = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return String.fromCharCodes(Iterable.generate(
        length, (_) => charset.codeUnitAt(random.nextInt(charset.length))));
  }

  Future<void> newUserExercise(String name, String muscleGroup) async {
    try {
      String? uid = user?.uid;

      if (uid != null) {
        // Reference to the specific document
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('user_exercises') // Parent collection
            .doc(uid); // User ID document


        // Check if the document exists
        DocumentSnapshot docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          // Document exists, update the 'exercises' array
          await docRef.update({
            'exercises': FieldValue.arrayUnion([
              {'name': name, 'muscleGroup': muscleGroup}
            ])
          });
        } else {
          // Document does not exist, create it with the 'exercises' array
          await docRef.set({
            'exercises': [
              {'name': name, 'muscleGroup': muscleGroup}
            ]
          });
        }

        print("User Exercise added successfully!");
      } else {
        throw Exception('User UID is null');
      }
    } catch (error) {
      print("Failed to add user exercise: $error");
    }
  }

  Future<List<Exercise>> fetchExercises() async {
    String? uid = user?.uid;

    try {
      List<Exercise> exercisesData = [];

      // Fetch exercises from user-specific path if uid is available
      if (uid != null) {
        DocumentReference userExercisesRef = FirebaseFirestore.instance
            .collection('user_exercises')
            .doc(uid);

        DocumentSnapshot userExercisesSnapshot = await userExercisesRef.get();

        if (userExercisesSnapshot.exists) {
          List<dynamic> exercisesArray =
              userExercisesSnapshot.get('exercises') ?? [];

          exercisesData = exercisesArray.map((exerciseMap) {
            return Exercise(
              id: exerciseMap['id'] ?? '',
              name: exerciseMap['name'] ?? '',
              muscleGroup: exerciseMap['muscleGroup'] ?? '',
            );
          }).toList();
        } else {
          print("User exercises document does not exist");
        }
      }

      // Fetch exercises from general path 'exercises'
      CollectionReference exercisesRef =
      FirebaseFirestore.instance.collection('exercises');

      QuerySnapshot exercisesSnapshot = await exercisesRef.get();

      List<Exercise> exercisesFromGeneralPath = exercisesSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Exercise(
          id: doc.id,
          name: data['name'],
          muscleGroup: data['muscleGroup'],
        );
      }).toList();

      // Combine data from both paths
      exercisesData.addAll(exercisesFromGeneralPath);

      return exercisesData;
    } catch (error) {
      print("Failed to fetch exercises: $error");
      return []; // Return empty list in case of failure
    }
  }


  Future<List<String>> fetchExerciseIds() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('exercises').get();

    List<String> exerciseIds = [];
    querySnapshot.docs.forEach((doc) {
      exerciseIds.add(doc.id);
    });

    return exerciseIds;
  }

  Future<List<Exercise?>> fetchById(List<String> exerciseIds) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('exercises')
          .where(FieldPath.documentId, whereIn: exerciseIds)
          .get();

      List<Exercise?> exercises = querySnapshot.docs.map((doc) {
        if (doc.exists) {
          return Exercise.fromSnapshot(doc);
        } else {
          // Exercise with the given ID does not exist
          return null;
        }
      }).toList();

      return exercises;
    } catch (e) {
      // Error occurred while fetching exercises
      print("Error fetching exercises: $e");
      return [];
    }
  }

  Future<void> updateExercises(String exerciseId, String? newName,
      String? newMuscleGroup) {
    CollectionReference exercises = FirebaseFirestore.instance.collection(
        'exercises');

    List<Future> futures = [];

    if (newName != null) {
      futures.add(exercises.doc(exerciseId).update({'name': newName})
          .then((value) => print("Exercise name updated successfully!"))
          .catchError((error) =>
          print("Failed to update exercise name: $error")));
    }
    if (newMuscleGroup != null) {
      futures.add(
          exercises.doc(exerciseId).update({'muscleGroup': newMuscleGroup})
              .then((value) =>
              print("Exercise muscle group updated successfully!"))
              .catchError((error) =>
              print("Failed to update exercise muscle group: $error")));
    }

    // Return a Future that resolves when all update operations are completed.
    return Future.wait(futures);
  }

  Future<void> deleteExercise(String exerciseId) {
    CollectionReference exercises = FirebaseFirestore.instance.collection(
        'exercises');

    return exercises.doc(exerciseId).delete()
        .then((value) => print("Exercise deleted successfully!"))
        .catchError((error) => print("Failed to delete exercise: $error"));
  }
}