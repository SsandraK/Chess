import 'package:flutter/material.dart';
import 'package:squares/squares.dart';

PieceSet getChessPieceSet() {
  return PieceSet(
    pieces: {
      'P': (context) => Image.asset('assets/pieces/white_pawn.png'),
      'N': (context) => Image.asset('assets/pieces/white_knight.png'),
      'B': (context) => Image.asset('assets/pieces/white_bishops.png'),
      'R': (context) => Image.asset('assets/pieces/white_rooks.png'),
      'Q': (context) => Image.asset('assets/pieces/white_queen.png'),
      'K': (context) => Image.asset('assets/pieces/white_king.png'),
      'p': (context) => Image.asset('assets/pieces/black_pawn.png'),
      'n': (context) => Image.asset('assets/pieces/black_knight.png'),
      'b': (context) => Image.asset('assets/pieces/black_bishops.png'),
      'r': (context) => Image.asset('assets/pieces/black_rooks.png'),
      'q': (context) => Image.asset('assets/pieces/black_queen.png'),
      'k': (context) => Image.asset('assets/pieces/black_king.png'),
    },
  );
}
