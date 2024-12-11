import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hash the password using SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to UTF-8 bytes
    final hashedPassword = sha256.convert(bytes); // Hash using SHA-256
    return hashedPassword.toString();
  }

  // Save user to Firestore
  Future<void> saveUser({required String username, required String password}) async {
    try {
      // Hash the password
      final hashedPassword = hashPassword(password);

      // Define user data to save
      Map<String, dynamic> userData = {
        "username": username,
        "password": hashedPassword,
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Save to Firestore using the username as the document ID
      await _firestore.collection('users').doc(username).set(userData);
      print('User saved successfully');
      notifyListeners();
    } catch (e) {
      print('Failed to save user: $e');
      throw e;
    }
  }

  // Authenticate user manually by checking username and hashed password
  Future<bool> authenticateUser({required String username, required String password}) async {
    try {
      final hashedPassword = hashPassword(password);

      // Fetch the user document
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
}
