import 'dart:async';
import 'package:chess_game/helpers/user.dart';
import 'package:chess_game/helpers/waitingroom.dart';
import 'package:chess_game/main.dart';
import 'package:chess_game/providers/database_provider.dart';
import 'package:chess_game/providers/user_provider.dart';
import 'package:chess_game/screens/game_screen.dart';
import 'package:flutter/material.dart';

class WaitingRoomProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
final UserProvider _userProvider;


  WaitingRoom? _currentRoom;
  String? _errorMessage;
  bool _isLoading = false;
  StreamSubscription? _guestSubscription;
  bool _isGuestListenerSet = false;


 WaitingRoomProvider(this._databaseService, this._userProvider);

  // Getters
  WaitingRoom? get currentRoom => _currentRoom;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  
 
Future<void> createRoom(WaitingRoom room) async {
  _setLoading(true);
  try {
    final forcedOwner = room.owner.copyWith(isWhite: true);
  
    final updatedRoom = room.copyWith(
      owner: forcedOwner,
   
    );

    await _databaseService.addRoomToDB(updatedRoom);
    _currentRoom = updatedRoom;
    _guestSubscription?.cancel();
    listenToRoomGuestUpdates(updatedRoom.roomId);
  } catch (e) {
    _errorMessage = 'Error creating room: $e';
    print(_errorMessage);
  } finally {
    _setLoading(false);
    notifyListeners();
  }
}

    Future<void> fetchRoom(String roomId) async {
    _setLoading(true);
    try {
      _currentRoom = await _databaseService.fetchWaitingRoom(roomId);
      if (_currentRoom != null) {
        _guestSubscription?.cancel();
        listenToRoomGuestUpdates(roomId);
      }
    } catch (e) {
      _errorMessage = 'Error fetching room: $e';
      print(_errorMessage);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }


Future<void> joinRoom(String roomId, Username guest) async {
  _setLoading(true);
  try {
    final room = await _databaseService.fetchWaitingRoom(roomId);
    if (room == null) {
      _errorMessage = 'No room found.';
      notifyListeners();
      return;
    }

    if (room.guest != null) {
      _errorMessage = 'Room is already full.';
      notifyListeners();
      return;
    }

    final updatedRoom = room.copyWith(guest: guest);
    await _databaseService.updateRoomInDB(updatedRoom);
    _currentRoom = updatedRoom;
    _guestSubscription?.cancel();
    listenToRoomGuestUpdates(roomId);

    print('Guest successfully joined the room.');
  } catch (e) {
    _errorMessage = 'Error joining room: $e';
    print('Error joining room: $e');
  } finally {
    _setLoading(false);
    notifyListeners();
  }
}

  Future<void> leaveRoom(Username user) async {
    if (_currentRoom == null) {
      _errorMessage = 'No room to leave.';
      notifyListeners();
      return;
    }

    try {
      if (_currentRoom!.owner.uuid == user.uuid) {
        await _databaseService.deleteRoomFromDB(_currentRoom!.roomId);
        _currentRoom = null;
      } else if (_currentRoom!.guest?.uuid == user.uuid) {
        final updatedRoom = _currentRoom!.copyWith(guest: null);
        await _databaseService.updateRoomInDB(updatedRoom);
        _currentRoom = updatedRoom;
      }

      _guestSubscription?.cancel();
      _isGuestListenerSet = false;
    } catch (e) {
      _errorMessage = 'Error leaving room: $e';
      print(_errorMessage);
    } finally {
      notifyListeners();
    }
  }


void listenToRoomGuestUpdates(String roomId) {
  final roomRef = _databaseService.getPath('rooms').child(roomId);

  _guestSubscription = roomRef.onValue.listen((event) {
    if (event.snapshot.value != null) {
      final roomData = Map<String, dynamic>.from(event.snapshot.value as Map);
      _currentRoom = WaitingRoom.fromRTDB(roomData);
      notifyListeners();

      // Check for guest 
      if (_currentRoom?.guest != null && _currentRoom?.owner.uuid != _userProvider.user?.uuid) {
        Future.microtask(() {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (context) => GameScreen(
                roomId: _currentRoom!,
              ),
            ),
          );
        });
      }
    }
  });
}

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

    @override
  void dispose() {
    _guestSubscription?.cancel();
    super.dispose();
  }
}


