# :chess_pawn: Real-Time Chess

This application is a real-time chess game built with Flutter. It leverages Firebase for live, real-time interactions between players. Players can create a username, join a waiting room, and wait for an opponent. Once both players are ready, the game begins. The app ensures smooth gameplay with notifications and rules enforcement.

## :bookmark_tabs: Table of Contents

1. [Installation]
2. [Implementation]
3.[Folder Sructure]
4. [For Auditors]
5. [Rules of Chess]

### :inbox_tray: Installation

To run this application, you need to:
* Install Flutter and Dart.
* Set up Android Studio (or another preferred IDE) and emulators.

1. **Clone the Repository:**

 ```bash
   git clone https://01.kood.tech/git/skannik/chess
   cd chess
   ```

2. **Install Flutter SDK:**

 ```flutter pub get ```

3. **Run the application:**

```flutter run```

## :hammer: Implementation

This app includes the following key features:

* Real-Time Multiplayer: Play chess against opponents in real-time.

* Move Validation: Prevent illegal moves using the chess package.

* Notifications: Notify players when it's their turn to play.

* Game Over Scenarios: Handle checkmate, stalemate, and draw conditions.

### :file_folder: Folder Structure
```
real_time_chess/
├── firebase_options.dart       # Firebase configuration settings
├── helpers/                    # Utility functions and helper classes
│   ├── commands.dart
│   ├── game.dart
│   ├── user.dart
│   └── waitingroom.dart
├── main.dart                   # Entry point of the Flutter application
├── providers/                  # State management logic using Provider
│   ├── game_provider.dart
│   ├── user_provider.dart
│   ├── waitingroom_provider.dart
│   └── database_provider.dart
├── screens/                    # UI screens for the app
│   ├── menu_screen.dart
│   ├── game_screen.dart
│   ├── waiting_room_screen.dart
│   └── login_screen.dart
├── widgets/                    # Reusable UI components
│   ├── menucard_widget.dart
│   ├── pieces_widget.dart
└── pubspec.yaml                # Project dependencies and metadata 
```

### :mag: For Auditors

If you do not wish to install Flutter, Dart, Android Studio, and emulators, I have provided pictures and written explanations for all the audit questions below.

Audit Questions

`Does the app run without crashing?`
Yes, the app runs smoothly without crashing.

`Does the app contain all the UI screens requested?`

Yes, the app includes:

Main Menu ![menu](/assets/images/menu.png)

Game Board ![board](/assets/images/board.png)

Waiting Room ![wr](/assets/images/wr.png)


`Try performing illegal moves (e.g., moving a pawn 3 squares up, castling after moving the king, moving a rook diagonally).`
The app prevents illegal moves using the Flutter chess package, which validates every move.

`Does the app prevent illegal moves?`
Yes, it ensures no illegal moves can be made.

`Play the game until one player is mated. Does the game end correctly?`

Yes, the game ends with notifications for checkmate, stalemate, or draw.

`Does the app have a multiplayer mode for real-time matches?`
Yes, it supports real-time multiplayer gameplay.

`When two players join a game session, does the player with the white pieces play first?`
Yes, the app enforces that the White player always starts first.

`Does the app have a notification system to alert players when it's their turn?`
Yes, the app displays a notification at the bottom showing the current turn.
![turn](/assets/images/turn.png)

`After a move is played, does the other player receive the move?`
Yes, the opponent is notified, and the board updates in real-time.

`Does the game end and notify the winner?`
Yes, the app notifies the winner or a draw.

![won](/assets/images/won.png)  ![over](/assets/images/over.png)


### :book: Rules of Chess

If you need a refresher on chess rules, you can visit:
Learn How to Play Chess- `(https://www.chess.com/learn-how-to-play-chess)`

### :point_down: real-time chess 
`(https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExcnIzOHRhNXB2ejRzanN1dzMwcTJ1cTIxZmVjMGluMzRsZXRpeXF5biZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/eg8EPt472uqFbNyAdB/giphy.gif) `
