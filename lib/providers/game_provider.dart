import 'package:chess/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:squares/squares.dart';
import 'package:square_bishop/square_bishop.dart';

class GameProvider extends ChangeNotifier {
  late bishop.Game _game = bishop.Game(variant: bishop.Variant.standard());
  late SquaresState _state = _game.squaresState(Squares.white);

  bool _aiThinking = false;
  bool _flipBoard = false;
  bool _vsComputer = false;
  bool _isLoading = false;
  int _whiteScore = 0;
  int _blackScore = 0;

  Map<String, int> positionHistory = {};

void trackPosition(String boardHash) {
  if (positionHistory.containsKey(boardHash)) {
    positionHistory[boardHash] = positionHistory[boardHash]! + 1;
  } else {
    positionHistory[boardHash] = 1;
  }
}

bool isThreefoldRepetition(String boardHash) {
  return positionHistory[boardHash] == 3;
}

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

    // Update board state
  void updateState(SquaresState newState) {
    _state = newState;
    notifyListeners(); // Notify listeners to update the UI
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



// Game over logic
void gameOver({
  required BuildContext context,
  required bool whiteWon,
  required VoidCallback newGame,
}) {
  String resultsToShow;

  // Handle draw scenarios
  if (game.drawn) {
    resultsToShow = _getDrawMessage();

    // Update scores in case of a draw
    final whitesResult = game.result?.scoreString.split('-').first ?? '0';
    final blacksResult = game.result?.scoreString.split('-').last ?? '0';

    _whiteScore += int.tryParse(whitesResult) ?? 0;
    _blackScore += int.tryParse(blacksResult) ?? 0;
  }
  // Handle checkmate scenarios
  else if (whiteWon) {
    resultsToShow = 'Checkmate! White won!';
    _whiteScore += 1;
  } else {
    resultsToShow = 'Checkmate! Black won!';
    _blackScore += 1;
  }

  // Notify listeners for UI updates
  notifyListeners();

  // Show the game-over dialog
  _showGameOverDialog(context, resultsToShow, newGame);
}

String _getDrawMessage() {
  if (game.stalemate) {
    return 'Game drawn by stalemate!';
  } else if (isThreefoldRepetition(game.fen)) {
    return 'Game drawn by threefold repetition!';
  } else if (game.halfMoveRule) {
    return 'Game drawn by the fifty-move rule!';
  } else {
    return 'Game drawn!';
  }
}

// Reusable dialog for game-over scenarios
void _showGameOverDialog(BuildContext context, String message, VoidCallback newGame) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Game Over'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              newGame(); // Reset the game
            },
            child: const Text('New Game'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MenuScreen()),
                (route) => false, 
              );
            },
            child: const Text('Exit'),
          ),
        ],
      );
    },
  );
}
}






