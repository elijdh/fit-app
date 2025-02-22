import 'exercise.dart';

class Workout {
  final String id;
  late final String name;
  late final String? description;
  final String scheduled;
  late final List<String> exerciseIds;
  final String userUid;

  Workout({
    required this.id,
    required this.name,
    this.description,
    required this.scheduled,
    required this.exerciseIds,
    required this.userUid,
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'description': description,
      'exerciseIds': exerciseIds,
      'userUid': userUid
    };
  }

}