
import 'package:chess/providers/game_provider.dart';
import 'package:chess/widgets/piecees_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';
import 'package:bishop/bishop.dart' as bishop;


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _aiThinking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
     
      gameProvider.resetGame();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Handle a move
void _onMove(Move move) async {
  final gameProvider = context.read<GameProvider>();

  // Attempt to make the player's move
  if (gameProvider.game.makeSquaresMove(move)) {
    gameProvider.updateState(gameProvider.game.squaresState(Squares.white));
    if (_handleGameOver(gameProvider)) return;
  }

  // Handle the AI's turn if playing vs Computer
  if (gameProvider.vsComputer &&
      gameProvider.state.state == PlayState.theirTurn &&
      !_aiThinking) {
    await _handleAITurn(gameProvider);
  }

  _handleGameOver(gameProvider);
}

Future<void> _handleAITurn(GameProvider gameProvider) async {
  setState(() => _aiThinking = true);

  await Future.delayed(const Duration(milliseconds: 1500));
  gameProvider.game.makeRandomMove();
  setState(() => _aiThinking = false);

  // Update the board state after the AI's move
  gameProvider.updateState(gameProvider.game.squaresState(Squares.white));
}

bool _handleGameOver(GameProvider gameProvider) {
  if (gameProvider.game.gameOver) {
    // ignore: unrelated_type_equality_checks
    final whiteWon = gameProvider.game.turn == 'black'; 

    gameProvider.gameOver(
      context: context,
      whiteWon: whiteWon,
      newGame: gameProvider.resetGame,
    );

    return true; 
  }

  return false; 
}



  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Chess'),
        backgroundColor: const Color.fromARGB(255, 199, 227, 199),
        actions: [
          IconButton(
            onPressed: gameProvider.flipTheBoard, // Flip the board
            icon: const Icon(Icons.rotate_left),
          ),
          OutlinedButton(
            onPressed: () => gameProvider.resetGame(), // Reset the game
            child: const Text('New Game'),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          // Opponent's info
          const ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/user.png'),
            ),
            title: Text('Player 2'),
          ),

          // Chessboard
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: BoardController(
              state: gameProvider.flipBoard
                  ? gameProvider.state.board.flipped()
                  : gameProvider.state.board,
              playState: gameProvider.state.state,
              theme: BoardTheme.brown,
              moves: gameProvider.state.moves,
              onMove: _onMove, 
              onPremove: _onMove, 
              onSetPremove: (move) {
                if (move != null) _onMove(move);
              },
              markerTheme: MarkerTheme(
                empty: MarkerTheme.dot,
                piece: MarkerTheme.corners(),
              ),
              promotionBehaviour: PromotionBehaviour.autoPremove,
              pieceSet: getChessPieceSet(),
            ),
          ),

          // Player's info
          const ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/user01.png'),
            ),
            title: Text('Player 1'),
          ),

          // Score at the bottom
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'White',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${gameProvider.whiteScore}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Black',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${gameProvider.blackScore}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
