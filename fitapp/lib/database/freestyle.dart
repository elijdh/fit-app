import 'package:fitapp/database/exercise.dart';

class Freestyle {
  final String id;
  final bool active;
  final List<String> exerciseIds;
  final String? name;
  final String scheduled;
  final List<Map<String, dynamic>> exercises;
  final double timeElapsed;
  final String userUid;


  Freestyle({
    required this.id,
    required this.active,
    required this.exerciseIds,
    this.name,
    required this.scheduled,
    required this.exercises,
    required this.timeElapsed,
    required this.userUid,
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'active': active,
      'exerciseIds': exerciseIds,
      'name': name,
      'scheduled': scheduled,
      'exercises': exercises,
      'timeElapsed': timeElapsed,
      'userUid': userUid,
    };
  }

}