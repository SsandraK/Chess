import 'dart:async';
import 'package:bishop/bishop.dart';
import 'package:chess_game/helpers/game.dart';
import 'package:chess_game/helpers/waitingroom.dart';
import 'package:chess_game/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';
import 'package:chess/chess.dart' as chesslib;
class GameProvider extends ChangeNotifier {
  late bishop.Game _bishopGame;
  late SquaresState _state;

  GameModel? _game;
  bool _isMultiplayer = false;
  String myColor = 'white';
  bool _isInitialized = false;

  StreamSubscription? _multiplayerListener;
  String? _gameId;

  GameProvider() {
    _bishopGame = bishop.Game(variant: bishop.Variant.standard());
    _state = _bishopGame.squaresState(
      myColor == 'white' ? Squares.white : Squares.black,
    );
  }

  GameModel? get game => _game;
  bool get isMultiplayer => _isMultiplayer;
  bool get isInitialized => _isInitialized;
  SquaresState get state => _state;


  void initializeGame() {
    _isInitialized = true;
    notifyListeners();
  }

  void resetInitialization() {
    _isInitialized = false;
  }

  void setPlayerColor(String color) {
    myColor = color;
    _bishopGame = bishop.Game(variant: bishop.Variant.standard());
    _state = _bishopGame.squaresState(
      myColor == 'white' ? Squares.white : Squares.black,
    );
    notifyListeners();
  }

  void resetGame() {
    _bishopGame = bishop.Game(variant: bishop.Variant.standard());
    _state = _bishopGame.squaresState(
      myColor == 'white' ? Squares.white : Squares.black,
    );

    _game = GameModel(
      players: {},
      status: 'new',
      currentMove: 'white',
      fen: _bishopGame.fen,
      gameId: '',
    );

    resetInitialization();
    notifyListeners();
  }

  Future<void> startMultiplayerGame(
    String gameId,
    WaitingRoom waitingRoom,
    DatabaseService dbService,
  ) async {
    _isMultiplayer = true;
    _gameId = gameId;

    final gameData = await dbService.fetchGame(gameId);
    if (gameData == null) {
      final newGame = GameModel(
        players: {
          'white': waitingRoom.owner,
          'black': waitingRoom.guest!,
        },
        status: 'in-progress',
        currentMove: 'white',
        fen: chesslib.Chess.DEFAULT_POSITION,
        gameId: gameId,
      );

      await dbService.saveGame(gameId, newGame);
      _game = newGame;
    } else {
      _game = gameData;
      _bishopGame = bishop.Game(fen: _game!.fen);
      _state = _bishopGame.squaresState(
        myColor == 'white' ? Squares.white : Squares.black,
      );
    }

    _multiplayerListener = dbService.listenToGame(gameId, (updatedGame) {
      _game = updatedGame;
      _bishopGame = bishop.Game(fen: updatedGame.fen);
      _state = _bishopGame.squaresState(
        myColor == 'white' ? Squares.white : Squares.black,
      );
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> endMultiplayerGame(DatabaseService dbService) async {
    if (_gameId != null) {
      await dbService.updateGameStatus(_gameId!, 'game-over');
    }
    _isMultiplayer = false;
    _multiplayerListener?.cancel();
    notifyListeners();
  }

  String toAlgebraic(int squareIndex) {
    final rank = 8 - (squareIndex ~/ 8);
    final file = squareIndex % 8;
    final fileLetter = String.fromCharCode('a'.codeUnitAt(0) + file);
    return '$fileLetter$rank';
  }

  Future<void> handleMove(String moveString) async {
    try {
      print('Attempting move: $moveString');
      final chess = chesslib.Chess.fromFEN(_game?.fen ?? chesslib.Chess.DEFAULT_POSITION);

      final from = moveString.substring(0, 2);
      final to = moveString.substring(2, 4);
      final promotion = moveString.length > 4 ? moveString.substring(4) : null;

      final move = {
        'from': from,
        'to': to,
        if (promotion != null) 'promotion': promotion,
      };

      final success = chess.move(move);
      if (success == null) {
        print('Invalid move: $moveString');
        notifyInvalidMove();
        return;
      }
      print('FEN after move: ${chess.fen}');

      _bishopGame = bishop.Game(fen: chess.fen);
      _state = _bishopGame.squaresState(
        myColor == 'white' ? Squares.white : Squares.black,
      );

      _game = _game?.copyWith(
        fen: chess.fen,
        currentMove: chess.turn == chesslib.Color.BLACK ? 'black' : 'white',
        isCheckmate: chess.in_checkmate,
        isDraw: chess.in_draw,
      );
      notifyListeners();

      if (_isMultiplayer && _gameId != null) {
        await DatabaseService().updateGame(_gameId!, _game!);
      }

      if (await handleGameOver()) {
        print('Game Over detected.');
      }
    } catch (e) {
      print('Error handling move: $e');
    }
  }

  Future<bool> handleGameOver() async {
    if (_game == null) return false;

    final isCheckmate = _game?.isCheckmate ?? false;
    final isDraw = _game?.isDraw ?? false;

    if (isCheckmate || isDraw) {
      final winner = isCheckmate
          ? (_game!.currentMove == 'black' ? 'white' : 'black')
          : null;

      _game = _game?.copyWith(
        status: 'game-over',
        winner: winner != null ? _game?.players[winner] : null,
      );

      if (_isMultiplayer && _gameId != null) {
        await DatabaseService().updateGame(_gameId!, _game!);
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  void notifyInvalidMove() {
    print('Invalid move attempted.');
  }

  @override
  void dispose() {
    _multiplayerListener?.cancel();
    super.dispose();
  }
}
