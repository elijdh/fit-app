import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/database/exercise.dart';
import 'package:fitapp/database/freestyle.dart';
import 'package:fitapp/database/workout.dart';

class FreestyleDB {
  User? user = FirebaseAuth.instance.currentUser;

  Future<String> newFreestyle(String? name, List<String> exerciseIds, List<Map<String, dynamic>> exercises, String? date, String? userUid, double? timeElapsed) async {
    CollectionReference freestyles = FirebaseFirestore.instance.collection(
        'freestyles');

    DocumentReference docRef = await freestyles.add({
      'name': name,
      'exerciseIds': exerciseIds,
      'exercises': exercises.isEmpty
          ? [] // Set exercises as an empty list initially
          : exercises,
      'scheduled': date,
      'userUid': userUid,
      'timeElapsed': timeElapsed,
      'active' : true,
    });

    return docRef.id;
  }

  Future<bool> hasActiveFreestyle(String uuid) async {
    CollectionReference freestyles = FirebaseFirestore.instance.collection('freestyles');

    QuerySnapshot snapshot = await freestyles.where('userUid', isEqualTo: uuid).where('active', isEqualTo: true).limit(1).get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> changeActiveStatus(String freestyleId) async {
    CollectionReference freestyles = FirebaseFirestore.instance.collection('freestyles');
    DocumentReference freestyleDoc = freestyles.doc(freestyleId);
    await freestyleDoc.update({
      "active" : false
    });
  }

  Future<Freestyle?> fetchActiveFreestyle(String uuid) async {
    final freestyles = FirebaseFirestore.instance.collection('freestyles');
    try {
      QuerySnapshot snapshot = await freestyles
          .where('userUid', isEqualTo: uuid)
          .where('active', isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Convert the exercises map from the snapshot into the correct format
        List<Map<String, dynamic>> exercises = [];
        if (data['exercises'] is List) {
          for (var exerciseData in data['exercises']) {
            if (exerciseData is Map<String, dynamic>) {
              exercises.add(exerciseData);
            } else {
              // Handle invalid exercise data (e.g., log an error)
              print("Invalid exercise data in freestyle: $exerciseData");
            }
          }
        }

        List<String> exerciseIds = (data['exerciseIds'] as List<dynamic>)
            .map((id) => id.toString())
            .toList();

        return Freestyle(
          id: doc.id,
          active: data['active'],
          exerciseIds: exerciseIds,
          scheduled: data['scheduled'],
          exercises: exercises,
          timeElapsed: data['timeElapsed'],
          userUid: data['userUid'],
        );
      } else {
        print('No active freestyle workout found under UUID: $uuid');
        return null;
      }
    } catch (error) {
      print("Failed to fetch freestyle workout: $error");
      return null;
    }
  }

  Future<void> addExercise(String freestyleId, String exerciseId) async {
    CollectionReference freestyles = FirebaseFirestore.instance.collection(
        'freestyles');

    bool contains = false;
    DocumentReference freestyleDoc = freestyles.doc(freestyleId);

    DocumentSnapshot snapshot = await freestyleDoc.get();

    await freestyleDoc.update({
      'exercises': FieldValue.arrayUnion([{'sets': []}])
    });

    late List<String>exerciseIds;
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      exerciseIds = List<String>.from(data['exerciseIds']);
      if (exerciseIds.contains(exerciseId)){
        exerciseIds.add(exerciseId);
        contains = true;
      } else {
        contains = false;
      }
    }

    if (contains == true) {
      return freestyleDoc.update({'exerciseIds' : exerciseIds});
    } else {
      return freestyles.doc(freestyleId).update({
        "exerciseIds": FieldValue.arrayUnion([exerciseId])})
          .then((value) => print("Exercise added to freestyle workout!"))
          .catchError((error) => print("Failed to add exercise: $error"));
    }

  }

  Future<void> removeExercise(String freestyleId, int exerciseIndex) async {
    CollectionReference freestyles = FirebaseFirestore.instance.collection(
        'freestyles');
    DocumentReference freestyleDoc = freestyles.doc(freestyleId);

    DocumentSnapshot snapshot = await freestyleDoc.get();
    late List<String>exerciseIds;
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      exerciseIds = List<String>.from(data['exerciseIds']);
      exerciseIds.removeAt(exerciseIndex);
      freestyleDoc.update({'exerciseIds' : exerciseIds});
    }
  }

  Future<bool> addSet(String freestyleId, int exerciseIndex) async {
    final freestyles = FirebaseFirestore.instance.collection('freestyles');
    final freestyleDoc = freestyles.doc(freestyleId);
    exerciseIndex = exerciseIndex - 1;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(freestyleDoc);
        final data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> exercises = data['exercises'];
        print("Hello $exercises");
        if (exerciseIndex >= 0) {
          // Access the sets array for this specific exercise

          List<dynamic> exerciseSets = exercises[exerciseIndex]['sets'];

          // Add the new set
          exerciseSets.add({"reps": null, "weight": null});

          // Update the exercises array and the document
          transaction.update(freestyleDoc, {'exercises': exercises});
        } else {
          // Exercise index is out of bounds
          throw Exception('Invalid exercise index');
        }
      });
      return true; // Indicate success
    } catch (error) {
      print("Failed to add set: $error");
      return false; // Indicate failure
    }
  }

  Future<bool> removeSet(String freestyleId, int exerciseIndex) async { // Remove setIndex parameter
    final freestyles = FirebaseFirestore.instance.collection('freestyles');
    final freestyleDoc = freestyles.doc(freestyleId);

    exerciseIndex = exerciseIndex - 1;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(freestyleDoc);
        final data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> exercises = data['exercises'];

        // Validation
        if (exerciseIndex < 0 || exerciseIndex >= exercises.length) {
          throw Exception('Invalid exercise index');
        }
        List<dynamic> exerciseSets = exercises[exerciseIndex]['sets'];
        if (exerciseSets.isEmpty) {
          throw Exception('No sets to remove for this exercise');
        }

        // Remove the last set (highest index)
        exerciseSets.removeLast();

        // Update the exercises array and the document
        transaction.update(freestyleDoc, {'exercises': exercises});
      });
      return true;
    } catch (error) {
      print("Failed to remove set: $error");
      return false;
    }
  }

  Future<bool> updateSet(
      String freestyleId,
      int exerciseIndex,
      int setIndex,
      {int? reps, double? weight} // Use named parameters with nullable types
      ) async {
    final freestyles = FirebaseFirestore.instance.collection('freestyles');
    final freestyleDoc = freestyles.doc(freestyleId);

    exerciseIndex = exerciseIndex - 1;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(freestyleDoc);
        final data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> exercises = data['exercises'];

        // Check for valid indices
        if (exerciseIndex < 0 || exerciseIndex >= exercises.length) {
          throw Exception('Invalid exercise index');
        }
        List<dynamic> sets = exercises[exerciseIndex]['sets'];
        if (setIndex < 0 || setIndex >= sets.length) {
          throw Exception('Invalid set index');
        }

        // Get the existing set data
        Map<String, dynamic> existingSet = sets[setIndex];

        // Update only the fields that are provided
        if (reps != null) {
          existingSet['reps'] = reps;
        }
        if (weight != null) {
          existingSet['weight'] = weight;
        }

        // Update the sets array in the exercise and the document
        exercises[exerciseIndex]['sets'] = sets;
        transaction.update(freestyleDoc, {'exercises': exercises});
      });
      return true;
    } catch (error) {
      print("Failed to update set: $error");
      return false;
    }
  }
}