import 'package:chess/providers/game_provider.dart';
import 'package:chess/widgets/piecees_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:squares/squares.dart';


class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

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
        backgroundColor: const Color.fromARGB(255, 224, 246, 157),
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
      body: Center(
        child: Column(
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
                onMove: (move) => gameProvider.onMove(move), 
            // TODO: check gameOver!!
                onPremove: (move) => gameProvider.onMove(move),
                onSetPremove: (move) {
                  if (move != null) gameProvider.onMove(move);
                },
                markerTheme: MarkerTheme(
                  empty: MarkerTheme.dot,
                  piece: MarkerTheme.corners(),
                ),
                promotionBehaviour: PromotionBehaviour.autoPremove,
               pieceSet:getChessPieceSet(),
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
          ],
        ),
      ),
    );
  }
}