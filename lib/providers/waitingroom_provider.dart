import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WaitingRoomProvider with ChangeNotifier {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _waitingUsers = [];

  // Getter 
  List<Map<String, dynamic>> get waitingUsers => _waitingUsers;

  // Add user to the waiting room
Future<void> joinWaitingRoom(String username) async {
  try {
    await _firestore.collection('waitingRoom').doc(username).set({
      'username': username,
      'isActive': true,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    print('$username joined the waiting room.');
  } catch (e) {
    print('Failed to join waiting room: $e');
    throw e;
  }
}


  // Remove user from the waiting room
Future<void> leaveWaitingRoom(String username) async {
  try {
    await _firestore.collection('waitingRoom').doc(username).update({
      'isActive': false,
    });
    print('$username left the waiting room.');
  } catch (e) {
    print('Failed to leave waiting room: $e');
    throw e;
  }
}


  // Fetch waiting users in real-time
void fetchWaitingUsers() {
  _firestore
      .collection('waitingRoom')
      .where('isActive', isEqualTo: true) // Fetch only active users
      .snapshots()
      .listen((snapshot) {
    _waitingUsers = snapshot.docs.map((doc) => doc.data()).toList();
    notifyListeners(); // Notify listeners about the changes
  });
}


 void sendGameNotification(BuildContext context, String fromUsername, String toUsername) {
    _firestore.collection('notifications').add({
      'type': 'gameInvite',
      'from': fromUsername,
      'to': toUsername,
      'message': '$fromUsername has invited you to a game!',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Game invite sent to $toUsername!')),
    );
  }


}