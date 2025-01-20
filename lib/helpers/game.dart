import 'package:chess_game/helpers/user.dart';
import 'package:equatable/equatable.dart';


class GameModel extends Equatable {
  final Map<String, Username> players; 
  final String status; 
  final String currentMove; 
  final String fen; 
  final String gameId; 
  final bool isCheckmate; 
  final bool isDraw; 
  final Username? winner; 

  const GameModel({
    required this.players,
    required this.status,
    required this.currentMove,
    required this.fen,
    required this.gameId,
    this.isCheckmate = false,
    this.isDraw = false,
    this.winner,
  });

  factory GameModel.fromRTDB(Map<String, dynamic> data) {
    try {
      // Parse players map
      final rawPlayers = data['players'];
      Map<String, Username> players = {};
      if (rawPlayers is Map) {
        rawPlayers.forEach((key, value) {
          if (value is Map) {
            players[key] = Username.fromRTDB(Map<String, dynamic>.from(value));
          } else {
            throw Exception('Invalid player data for key: $key');
          }
        });
      } else {
        throw Exception('Invalid players data type');
      }

      Username? winner;
      if (data['winner'] != null && data['winner'] is Map) {
        winner = Username.fromRTDB(Map<String, dynamic>.from(data['winner']));
      }

      return GameModel(
        players: players,
        status: data['status'] as String? ?? 'unknown',
        currentMove: data['current_move'] as String? ?? 'white',
        fen: data['fen'] as String? ?? '',
        gameId: data['game_id'] as String? ?? '',
        isCheckmate: data['is_checkmate'] as bool? ?? false,
        isDraw: data['is_draw'] as bool? ?? false,
        winner: winner,
      );
    } catch (e) {
      throw Exception('Error parsing GameModel from RTDB: $e');
    }
  }

  GameModel copyWith({
    Map<String, Username>? players,
    String? status,
    String? currentMove,
    String? fen,
    String? gameId,
    bool? isCheckmate,
    bool? isDraw,
    Username? winner,
  }) {
    return GameModel(
      players: players ?? this.players,
      status: status ?? this.status,
      currentMove: currentMove ?? this.currentMove,
      fen: fen ?? this.fen,
      gameId: gameId ?? this.gameId,
      isCheckmate: isCheckmate ?? this.isCheckmate,
      isDraw: isDraw ?? this.isDraw,
      winner: winner ?? this.winner,
    );
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'players': players.map((key, user) => MapEntry(key, user.toJson())),
        'status': status,
        'current_move': currentMove,
        'fen': fen,
        'game_id': gameId,
        'is_checkmate': isCheckmate,
        'is_draw': isDraw,
        'winner': winner?.toJson(),
      };
    } catch (e) {
      throw Exception('Error converting GameModel to JSON: $e');
    }
  }

  @override
  List<Object?> get props => [
        players,
        status,
        currentMove,
        fen,
        gameId,
        isCheckmate,
        isDraw,
        winner,
      ];
}
