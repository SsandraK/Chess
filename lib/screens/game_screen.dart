import 'dart:math';
import 'package:bishop/bishop.dart' as bishop;
import 'package:flutter/material.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late bishop.Game game;
  late SquaresState state;
  int player = Squares.white;
  bool aiThinking = false;
  bool flipBoard = false;

  @override
  void initState() {
    super.initState();
    _resetGame(false);
  }

  void _resetGame([bool setstate = true]) {
    game = bishop.Game(variant: bishop.Variant.standard());
    state = game.squaresState(player);
    if (setstate) setState(() {});
  }

  void _flipBoard() => setState(() => flipBoard = !flipBoard);

  void _onMove(Move move) async {
    bool result = game.makeSquaresMove(move);
    if (result) {
      setState(() => state = game.squaresState(player));
    }

    if (state.state == PlayState.theirTurn && !aiThinking) {
      setState(() => aiThinking = true);
      await Future.delayed(
          Duration(milliseconds: Random().nextInt(4750) + 250));
      game.makeRandomMove();
      setState(() {
        aiThinking = false;
        state = game.squaresState(player);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
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
      onPressed: _flipBoard, // Flip board 
      icon: const Icon(Icons.rotate_left),
    ),
    OutlinedButton(
      onPressed: () => _resetGame(true), 
      child: const Text('New Game'),
    ),
  ],
),

      body: Center(
        child: Column(
        //  mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Opponents info
            const ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              title: Text('Player2 name'),
            ),

            Padding(
              padding: const EdgeInsets.all(4.0),
              child: BoardController(
                state: flipBoard ? state.board.flipped() : state.board,
                playState: state.state,
                theme: BoardTheme.brown,
                moves: state.moves,
                onMove: _onMove,
                onPremove: _onMove,
                onSetPremove: (move) {
                  if (move != null) _onMove(move);
                  debugPrint('Premove set: $move');
                },
                markerTheme: MarkerTheme(
                  empty: MarkerTheme.dot,
                  piece: MarkerTheme.corners(),
                ),
                promotionBehaviour: PromotionBehaviour.autoPremove,
                pieceSet: PieceSet(
                  pieces: {
                    'P': (context) =>
                        Image.asset('assets/pieces/white_pawn.png'),
                    'N': (context) =>
                        Image.asset('assets/pieces/white_knight.png'),
                    'B': (context) =>
                        Image.asset('assets/pieces/white_bishops.png'),
                    'R': (context) =>
                        Image.asset('assets/pieces/white_rooks.png'),
                    'Q': (context) =>
                        Image.asset('assets/pieces/white_queen.png'),
                    'K': (context) =>
                        Image.asset('assets/pieces/white_king.png'),
                    'p': (context) =>
                        Image.asset('assets/pieces/black_pawn.png'),
                    'n': (context) =>
                        Image.asset('assets/pieces/black_knight.png'),
                    'b': (context) =>
                        Image.asset('assets/pieces/black_bishops.png'),
                    'r': (context) =>
                        Image.asset('assets/pieces/black_rooks.png'),
                    'q': (context) =>
                        Image.asset('assets/pieces/black_queen.png'),
                    'k': (context) =>
                        Image.asset('assets/pieces/black_king.png'),
                  },
                ),
              ),
            ),

            //Current players info
            const ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/user01.png'),
              ),
              title: Text('Player1 name'),
            ),
          
          ],
        ),
      ),
    );
  }
}
