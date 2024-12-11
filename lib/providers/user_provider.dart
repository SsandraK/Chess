import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hash the password 
  String hashPassword(String password) {
    final bytes = utf8.encode(password); 
    final hashedPassword = sha256.convert(bytes); 
    return hashedPassword.toString();
  }

  // Save user to Firestore
  Future<void> saveUser({required String username, required String password}) async {
    try {
      final hashedPassword = hashPassword(password);

      Map<String, dynamic> userData = {
        "username": username,
        "password": hashedPassword,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(username).set(userData);
      print('User saved successfully');
      notifyListeners();
    } catch (e) {
      print('Failed to save user: $e');
      throw e;
    }
  }

  // Authenticate user by checking username and password
  Future<bool> authenticateUser({required String username, required String password}) async {
    try {
      final hashedPassword = hashPassword(password);
      final userDoc = await _firestore.collection('users').doc(username).get();

      if (userDoc.exists && userDoc.data()!['password'] == hashedPassword) {
        print('User authenticated successfully');
        return true;
      } else {
        print('Invalid username or password');
        return false;
      }
    } catch (e) {
      print('Failed to authenticate user: $e');
      throw e;
    }
  }

  // Check if user already exists in the waiting room or active games
  Future<bool> checkIfUserExists(String username) async {
    try {
      // Check if user exists in the waiting room
      final waitingRoomDoc = await _firestore.collection('waitingRoom').doc(username).get();
      if (waitingRoomDoc.exists) {
        print('User is already in the waiting room.');
        return true;
      }

      // Check if user exists in active games
      final activeGames = await _firestore.collection('games')
          .where('players', arrayContains: username)
          .get();
      if (activeGames.docs.isNotEmpty) {
        print('User is already in an active game.');
        return true;
      }

      return false;
    } catch (e) {
      print('Failed to check if user exists: $e');
      throw e;
    }
  }
}

