import 'package:chess_game/helpers/waitingroom.dart';
import 'package:chess_game/providers/database_provider.dart';
import 'package:chess_game/providers/user_provider.dart';
import 'package:chess_game/providers/game_provider.dart';
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

        print('Player color (myColor): $myColor');

        gameProvider.setPlayerColor(myColor);
        gameProvider.startMultiplayerGame(
          waitingRoom.roomId,
          waitingRoom,
          context.read<DatabaseService>(),
        );
        gameProvider.initializeGame();
      }
    });
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

      print('Attempting move: $moveString');
      print('Game state before move: ${gameProvider.state.board}');

      await gameProvider.handleMove(moveString);
      await checkAndHandleGameOver(gameProvider);
    } catch (e) {
      print('Error handling move: $e');
    }
  }

  Future<void> checkAndHandleGameOver(GameProvider gameProvider) async {
    if (await gameProvider.handleGameOver()) {
      showGameOverDialog(gameProvider);
    }
  }

  void showGameOverDialog(GameProvider gameProvider) {
    final isCheckmate = gameProvider.game?.isCheckmate ?? false;
    final isDraw = gameProvider.game?.isDraw ?? false;

    final message = isCheckmate
        ? '${gameProvider.game?.currentMove == 'white' ? 'Black' : 'White'} Wins by Checkmate!'
        : (isDraw ? 'It\'s a Draw!' : 'Game Over!');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); 
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
  final isBlackAtBottom = myColor == 'white';

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
          if (!isBlackAtBottom)
            PlayerInfo(
              username: blackPlayer?.username ?? 'Waiting for Player...',
              avatarPath: 'assets/images/user.png',
              role: 'Black',
            )
          else
            PlayerInfo(
              username: whitePlayer.username,
              avatarPath: 'assets/images/user01.png',
              role:'White',
            ),

          // Chessboard.
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

          if (isBlackAtBottom)
            PlayerInfo(
              username: blackPlayer?.username ?? 'Waiting for Player...',
              avatarPath: 'assets/images/user.png',
               role: 'Black',
            )
          else
            PlayerInfo(
              username: whitePlayer.username,
              avatarPath: 'assets/images/user01.png',
               role: 'White',
            ),

          // Current turn display.
          Container(
            color: const Color.fromARGB(255, 204, 232, 250),
            padding: const EdgeInsets.symmetric(vertical: 8.0,  horizontal: 10.0,),
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