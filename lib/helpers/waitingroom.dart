import 'package:chess_game/helpers/game.dart';
import 'package:equatable/equatable.dart';
import 'package:chess_game/helpers/user.dart';

class WaitingRoom extends Equatable {
  final Username owner;
  final String roomId;
  final Username? guest; 
  final GameModel? game;

  const WaitingRoom({
    required this.owner,
    required this.roomId,
    this.guest,           
    this.game,
  });

  factory WaitingRoom.fromRTDB(Map<String, dynamic> data) {
    final ownerData = data['owner'] as Map<dynamic, dynamic>?;
    final guestData = data['guest'] as Map<dynamic, dynamic>?;

    final owner = ownerData != null
        ? Username.fromRTDB(Map<String, dynamic>.from(ownerData))
        : Username(username: 'Unknown', uuid: '', isWhite: true);

    final guest = guestData != null
        ? Username.fromRTDB(Map<String, dynamic>.from(guestData))
        : null; 

    GameModel? game;
    if (data['game'] != null) {
      game = GameModel.fromRTDB(Map<String, dynamic>.from(data['game']));
    }

    return WaitingRoom(
      owner: owner,
      roomId: data['room_id'] ?? '',
      guest: guest,
      game: game,
    );
  }

  WaitingRoom copyWith({
    Username? owner,
    String? roomId,
    Username? guest,
    GameModel? game,
  }) {
    return WaitingRoom(
      owner: owner ?? this.owner,
      roomId: roomId ?? this.roomId,
      guest: guest ?? this.guest,
      game: game ?? this.game,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner': owner.toJson(),
      'room_id': roomId,
      'guest': guest?.toJson(),
      'game': game?.toJson(),
    };
  }

  @override
  List<Object?> get props => [owner, roomId, guest, game];
}
