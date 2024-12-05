import 'package:chess/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:squares/squares.dart';
import 'package:square_bishop/square_bishop.dart';
import 'dart:math';



class GameProvider extends ChangeNotifier {
  late bishop.Game _game = bishop.Game(variant: bishop.Variant.standard());
  late SquaresState _state = _game.squaresState(Squares.white);
  bool _aiThinking = false;
  bool _flipBoard = false;
  bool _vsComputer = false;
  bool _isLoading = false;
  int _whiteScore = 0;
  int _blackScore = 0;

  // Getters
  bool get vsComputer => _vsComputer;
  bool get isLoading => _isLoading;
  bishop.Game get game => _game;
  SquaresState get state => _state;
  bool get aiThinking => _aiThinking;
  bool get flipBoard => _flipBoard;
  int get whiteScore => _whiteScore;
  int get blackScore => _blackScore;

  // Setters
  void setVsComputer({required bool value}) {
    _vsComputer = value;
    notifyListeners();
  }

  void setIsLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  // Reset game
  void resetGame([bool notify = true]) {
    _game = bishop.Game(variant: bishop.Variant.standard());
    _state = _game.squaresState(Squares.white);
    if (notify) notifyListeners();
  }

  // Flip the board
  void flipTheBoard() {
    _flipBoard = !_flipBoard;
    notifyListeners();
  }

  // Handle a move
  void onMove(Move move) async {
    bool result = _game.makeSquaresMove(move);
    if (result) {
      _state = _game.squaresState(Squares.white);
      notifyListeners();
    }

    if (_state.state == PlayState.theirTurn && !_aiThinking) {
      _aiThinking = true;
      notifyListeners();

      await Future.delayed(Duration(milliseconds: 1500)); // Fixed delay for AI
      _game.makeRandomMove();

      _aiThinking = false;
      _state = _game.squaresState(Squares.white);
      notifyListeners();
    }
  
  }


// Game over logic
void gameOver({
  required BuildContext context,
  required bool whiteWon,
  required Function newGame,
}) {
  String result = whiteWon ? 'White won!' : 'Black won!';
  String resultsToShow = game.result?.readable ?? 'Game Over';

  // If the game is drawn, update resultsToShow and scores
  if (game.drawn) {
    resultsToShow = 'Game drawn!';
    String whitesResult = game.result?.scoreString.split('-').first ?? '0';
    String blacksResult = game.result?.scoreString.split('-').last ?? '0';

    // Update scores
    _whiteScore += int.tryParse(whitesResult) ?? 0;
    _blackScore += int.tryParse(blacksResult) ?? 0;
  } else {
    // Update winner's score
    if (whiteWon) {
      _whiteScore += 1;
    } else {
      _blackScore += 1;
    }
  }

  notifyListeners(); // Notify listeners to update UI if needed

  // Show the game-over dialog
  showGameOverDialog(context, resultsToShow, newGame);
}


  } 



  // Reusable dialog for game-over scenarios
  void showGameOverDialog(BuildContext context, String message, Function newGame) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

              },
              child: const Text('New Game'),
             ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
           Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => const MenuScreen()),
  (route) => false, // Remove all previous routes
);

                newGame();
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }


 


