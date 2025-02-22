import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
  });

  factory Exercise.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Exercise(
      id: snapshot.id,
      name: data['name'],
      muscleGroup: data['muscleGroup'],
      // Initialize other properties here...
    );
  }
}