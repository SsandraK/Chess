import 'dart:async';

import 'package:chess_game/helpers/game.dart';
import 'package:chess_game/helpers/waitingroom.dart';
import 'package:chess_game/providers/database_provider.dart';
import 'package:chess_game/providers/user_provider.dart';
import 'package:chess_game/providers/game_provider.dart';
import 'package:chess_game/screens/menu_screen.dart';
import 'package:chess_game/widgets/menucard_widget.dart';
import 'package:chess_game/widgets/piecees_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:squares/squares.dart' as squares;
class GameScreen extends StatefulWidget {
  final WaitingRoom roomId;

  const GameScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late String myColor = 'white';
  StreamSubscription? gameSubscription;
  bool isDialogShown = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
      final waitingRoom = widget.roomId;

      if (!gameProvider.isInitialized) {
        setState(() {
          myColor = waitingRoom.owner.uuid == context.read<UserProvider>().user?.uuid
              ? 'white'
              : 'black';
        });

        gameProvider.setPlayerColor(myColor);
        gameProvider.startMultiplayerGame(
          waitingRoom.roomId,
          waitingRoom,
          context.read<DatabaseService>(),
        );
        gameProvider.initializeGame();
      }

      // Subscribe to game updates
      final gameId = waitingRoom.roomId;
      gameSubscription = DatabaseService().listenToGame(gameId, (updatedGame) {
        if (updatedGame.status == 'game-over' && !isDialogShown) {
          setState(() {
            isDialogShown = true; 
          });
          showGameOverDialog(updatedGame);
        }
      });
    });
  }

  @override
  void dispose() {
    gameSubscription?.cancel(); 
    super.dispose();
  }

  Future<void> onMove(squares.Move move) async {
    final gameProvider = context.read<GameProvider>();
    try {
      final fromAlgebraic = gameProvider.toAlgebraic(move.from);
      final toAlgebraic = gameProvider.toAlgebraic(move.to);
      final moveString = '$fromAlgebraic$toAlgebraic';

      if (fromAlgebraic.isEmpty || toAlgebraic.isEmpty) {
        throw Exception('Invalid move coordinates.');
      }

      await gameProvider.handleMove(moveString);
      await checkAndHandleGameOver(gameProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error handling move: $e')),
      );
    }
  }

  Future<void> checkAndHandleGameOver(GameProvider gameProvider) async {
    if (await gameProvider.handleGameOver()) {
      final updatedGame = gameProvider.game; 
      if (updatedGame != null && !isDialogShown) {
        setState(() {
          isDialogShown = true; 
        });
        showGameOverDialog(updatedGame);
      }
    }
  }

  void showGameOverDialog(GameModel updatedGame) {
    final isCheckmate = updatedGame.isCheckmate;
    final isDraw = updatedGame.isDraw;
    final winner = updatedGame.winner;
    final currentUser = context.read<UserProvider>().user;

    String message;

    if (isCheckmate) {
      if (winner != null && winner.uuid == currentUser?.uuid) {
        message = 'Congratulations, ${currentUser?.username}! You won by Checkmate!';
      } else {
        message = 'Sorry, ${currentUser?.username}. You lose.';
      }
    } else if (isDraw) {
      message = 'It\'s a Draw!';
    } else {
      message = 'Game Over!';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => MenuScreen()),
                (route) => false,
              );
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final whitePlayer = widget.roomId.owner;
    final blackPlayer = widget.roomId.guest;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Chess Game'),
        backgroundColor: const Color.fromARGB(255, 105, 203, 252),
      ),
      body: BackgroundWidget(
        child: Column(
          children: [
            // Top Player Info
            PlayerInfo(
              username: myColor == 'white'
                  ? (blackPlayer?.username ?? 'Waiting for Player...')
                  : whitePlayer.username,
              avatarPath: myColor == 'white'
                  ? 'assets/images/user01.png'
                  : 'assets/images/user.png',
              role: myColor == 'white' ? 'Black' : 'White',
            ),

            // Chessboard
            Expanded(
              child: squares.BoardController(
                state: gameProvider.state.board,
                playState: gameProvider.state.state,
                theme: squares.BoardTheme.brown,
                moves: gameProvider.state.moves,
                onMove: onMove,
                markerTheme: squares.MarkerTheme(
                  empty: squares.MarkerTheme.dot,
                  piece: squares.MarkerTheme.corners(),
                ),
                promotionBehaviour: squares.PromotionBehaviour.autoPremove,
                pieceSet: getChessPieceSet(),
              ),
            ),

            // Bottom Player Info
            PlayerInfo(
              username: myColor == 'white'
                  ? whitePlayer.username
                  : (blackPlayer?.username ?? 'Waiting for Player...'),
              avatarPath: myColor == 'white'
                  ? 'assets/images/user.png'
                  : 'assets/images/user01.png',
              role: myColor == 'white' ? 'White' : 'Black',
            ),

            // Current Turn
            Container(
              color: const Color.fromARGB(255, 204, 232, 250),
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              child: Text(
                'Current Turn: ${gameProvider.game?.currentMove == 'white' ? 'White' : 'Black'}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
