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
    final existingUser = await _firestore.collection('users').doc(username).get();
    if (existingUser.exists) {
      throw Exception('Username already exists. Please choose a different username.');
    }

    // Hash the password
    final hashedPassword = hashPassword(password);

    // Define user data
    Map<String, dynamic> userData = {
      "username": username,
      "password": hashedPassword,
      "createdAt": FieldValue.serverTimestamp(),
    };

    // Save the user data
    await _firestore.collection('users').doc(username).set(userData);
    print('User saved successfully');
    notifyListeners();
  } catch (e) {
    print('Failed to save user: $e');
    throw e; // Propagate the error
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

listenToGameInvitations(BuildContext context, String userId) {
  _firestore
      .collection('notifications')
      .where('to', isEqualTo: userId)
      .snapshots()
      .listen((snapshot) {
    for (var doc in snapshot.docChanges) {
      if (doc.type == DocumentChangeType.added) {
        final data = doc.doc.data();
        if (data != null) {
          // Show the dialog for the new invitation
          _showGameInvitationDialog(context, data['from'], doc.doc.id);
        }
      }
    }
  });
}

void _showGameInvitationDialog(BuildContext context, String fromUser, String notificationId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Game Invitation'),
      content: Text('$fromUser has invited you to a game!'),
      actions: [
        TextButton(
          onPressed: () {
            // Handle "No" response
            _respondToGameInvitation(notificationId, accepted: false);
            Navigator.of(context).pop();
          },
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            // Handle "Yes" response
            _respondToGameInvitation(notificationId, accepted: true);
            Navigator.of(context).pop();
          },
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}

void _respondToGameInvitation(String notificationId, {required bool accepted}) async {
  try {
    final doc = await _firestore.collection('notifications').doc(notificationId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        final fromUser = data['from'];

        // Update the invitation response
        await _firestore.collection('notifications').doc(notificationId).update({
          'accepted': accepted,
          'respondedAt': FieldValue.serverTimestamp(),
        });

        // Notify the inviting user
        await _firestore.collection('notifications').add({
          'type': 'response',
          'from': fromUser,
          'to': data['to'], // Notify the inviter
          'message': accepted
              ? '${data['to']} accepted your game invitation!'
              : '${data['to']} declined your game invitation.',
          'timestamp': FieldValue.serverTimestamp(),
        });

        print('Invitation response sent: $accepted');
      }
    }
  } catch (e) {
    print('Failed to respond to invitation: $e');
  }
}


}

