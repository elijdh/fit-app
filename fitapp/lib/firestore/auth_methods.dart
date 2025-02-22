import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthNotifier extends ChangeNotifier {
  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  void setLoggedIn(bool value) {
    _loggedIn = value;
    notifyListeners();
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isUsernameTaken(String username) async {
    try {
      var querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking username: $e');
      return true;
    }
  }

  Future<Map<String, dynamic>?> getDataByUUID(String uuid) async {
    try {
      var querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uuid)
          .get();

      if (querySnapshot.docs.isNotEmpty){
        return querySnapshot.docs.first.data();
      } else{
        return null;
      }
    } catch (e) {
      print('Error getting user data by UUID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDataByUsername(String username) async {
    try {
      var querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty){
        return querySnapshot.docs.first.data();
      } else{
        return null;
      }
    } catch (e) {
      print('Error getting user data by username: $e');
      return null;
    }
  }
}