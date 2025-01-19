import 'dart:async';

import 'package:chess_game/helpers/game.dart';
import 'package:chess_game/helpers/user.dart';
import 'package:chess_game/helpers/waitingroom.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class DatabaseService extends ChangeNotifier {
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  static const kUsersPath = 'users';
  static const kRoomsPath = 'rooms';
  static const kGamesPath = 'games';

  DatabaseReference getPath(String path) => database.child(path);

//USERS
  Future<void> addUserToDB(Username user) async {
    final usersRef = getPath(kUsersPath); 
    print('addUserToDB invoked for user: ${user.username}, UUID: ${user.uuid}');
    try {
      print('Writing user data to database...');
      await usersRef
          .child(user.uuid)
          .set({
            'username': user.username,
            'uuid': user.uuid,
          })
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('Database write operation timed out!');
              throw Exception('Timeout while writing to database');
            },
          );
      print('User added successfully!');
    } catch (e) {
      print('Error adding user to database: ${e.runtimeType} - $e');
      throw Exception(e);
    }
  }

  Future<Username?> fetchUserFromDB(String username) async {
    final usersRef = getPath(kUsersPath);
    try {
      print('Attempting to fetch user with username: $username');
      print('Querying path: ${usersRef.path}');

      final snapshot = await usersRef.orderByChild('username').equalTo(username).get();

      print('Snapshot: ${snapshot.value}');
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from((snapshot.value as Map).values.first);
        print('User found: $data');
        return Username.fromRTDB(data);
      } else {
        print('No user found with username: $username');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
    return null;
  }


//ROOMS
Future<void> addRoomToDB(WaitingRoom room) async {
  final roomsRef = getPath(kRoomsPath);
  try {
    if (room.owner.username.isEmpty || room.owner.uuid.isEmpty) {
      throw Exception('Invalid owner data. Owner fields cannot be empty.');
    }

     if (room.guest != null &&
        (room.guest!.username.isEmpty || room.guest!.uuid.isEmpty)) {
      throw Exception('Invalid guest data. Guest fields cannot be empty.');
    }

    await roomsRef.child(room.roomId).set(room.toJson());
    print('Room added successfully!');
  } catch (e) {
    throw Exception('Error adding room: $e');
  }
}


Future<void> updateRoomInDB(WaitingRoom room) async {
  final roomRef = getPath(kRoomsPath).child(room.roomId);
  try {
    if (room.owner.username.isEmpty || room.owner.uuid.isEmpty) {
      throw Exception('Invalid owner data. Owner fields cannot be empty.');
    }
    await roomRef.update(room.toJson());
    print('Room updated successfully!');
  } catch (e) {
    throw Exception('Error updating room: $e');
  }
}


Future<void> updateRoomGuest(String roomId, Username? guest) async {
  final roomRef = getPath(kRoomsPath).child(roomId);
  try {
    if (guest != null) {
      await roomRef.update({
        'guest': guest.toJson(),
      });
    } else {
   
      await roomRef.update({
        'guest': null,
      });
      print('Guest removed successfully!');
    }
  } catch (e) {
    throw Exception('Error updating guest: $e');
  }
}

  Future<WaitingRoom?> fetchWaitingRoom(String roomId) async {
    final roomRef = getPath('$kRoomsPath/$roomId');
    try {
      final snapshot = await roomRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        final roomData = Map<String, dynamic>.from(snapshot.value as Map);
        return WaitingRoom.fromRTDB(roomData);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching the waiting room: $e');
    }
  }

  Future<void> deleteRoomFromDB(String roomId) async {
    final roomRef = getPath('$kRoomsPath/$roomId');
    try {
      await roomRef.remove();
    } catch (e) {
      print('Error deleting room: $e');
      throw Exception('Error deleting room: $e');
    }
  }


  //GAME DATA
Future<GameModel?> fetchGame(String gameId) async {
  try {
    final snapshot = await getPath('$kGamesPath/$gameId').get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
      return GameModel.fromRTDB(data);
    }
  } catch (e) {
    print('Error fetching game: $e');
    throw Exception('Error fetching game: $e');
  }
  return null;
}

  Future<void> saveGame(String gameId, GameModel game) async {
    try {
      await getPath('$kGamesPath/$gameId').set(game.toJson());
      print('Game saved successfully with ID: $gameId');
    } catch (e) {
      throw Exception('Error saving game: $e');
    }
  }

  Future<void> updateGame(String gameId, GameModel updatedGame) async {
    try {
      await getPath('$kGamesPath/$gameId').update(updatedGame.toJson());
      print('Game updated successfully with ID: $gameId');
    } catch (e) {
      throw Exception('Error updating game: $e');
    }
  }

  Future<void> updateGameStatus(String gameId, String status) async {
    try {
      await getPath('$kGamesPath/$gameId').update({'status': status});
      print('Game status updated to $status for game ID: $gameId');
    } catch (e) {
      print('Error updating game status: $e');
    }
  }

  StreamSubscription listenToGame(String gameId, void Function(GameModel game) onUpdate) {
    return getPath('$kGamesPath/$gameId').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final updatedGame = GameModel.fromRTDB(data);
        onUpdate(updatedGame);
      }
    });
  }
}








