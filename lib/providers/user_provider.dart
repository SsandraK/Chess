import 'dart:async';
import 'package:chess_game/helpers/user.dart';
import 'package:chess_game/providers/database_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UserProvider extends ChangeNotifier {
  
  Username? _user;
  final DatabaseService _databaseService = DatabaseService();
  final _firebaseDb = FirebaseDatabase.instance.ref();

  bool _isRegistering = false;
  String? _errorMessage;

  Username? get user => _user;
  bool get isRegistering => _isRegistering;
  String? get errorMessage => _errorMessage;
  bool get hasUser => _user != null;


  Future<void> addUser(String username) async {
    if (username.isEmpty || username.trim().isEmpty) {
      _errorMessage = 'Username cannot be empty';
      notifyListeners();
      return;
    }

    _isRegistering = true;
    _errorMessage = null;
    notifyListeners();

    try {
   final newUser = Username(
      username: username.trim(),
      uuid: const Uuid().v4(), 
      isWhite: true,
   
    );

      await _databaseService.addUserToDB(newUser);
      _user = newUser;
    } catch (e) {
      _errorMessage = 'Error adding user: $e';
      print(_errorMessage);
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }

  Future<void> loginUser(String username) async {
    if (username.isEmpty || username.trim().isEmpty) {
      _errorMessage = 'Username cannot be empty';
      notifyListeners();
      return;
    }

    _isRegistering = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedUser = await _databaseService.fetchUserFromDB(username);

      if (fetchedUser != null) {
        _user = fetchedUser;
        print('Login successful: ${_user?.username}');
      } else {
        _errorMessage = 'User not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to login: $e';
      print(_errorMessage);
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _isRegistering = false;
    _errorMessage = null;
    notifyListeners();
  }
}
