# :chess_pawn: Real-Time Chess

This application is a real-time chess game built with Flutter. It leverages Firebase for live, real-time interactions between players. Players can create a username, join a waiting room, and wait for an opponent. Once both players are ready, the game begins. The app ensures smooth gameplay with notifications and rules enforcement.

## :bookmark_tabs: Table of Contents

1. [Installation](#inbox_tray-installation)
2. [Implementation](#hammer-implementation)
3. [Folder Structure](#file_folder-folder-structure)
4. [Features](#mag-for-auditors)
5. [Rules](#book-rules-of-chess)


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

### ✨ Features

`This app includes:`

 * Main Menu ![menu](/assets/images/menu.png)

 * Game Board ![board](/assets/images/board.png)

 * Waiting Room ![wr](/assets/images/wr.png)



- 🔒 **Move Validation**  
  Illegal moves are completely prevented. The app uses the `flutter_chess_board` package to validate all moves according to official chess rules.

- 🎮 **Multiplayer Mode**  
  Play real-time chess matches with another player. Once both players are in the waiting room, simply press the Start button to begin the game!

- ♟️ **Turn Indicator**  
  A notification at the bottom of the board shows whose turn it is.  
  ![Turn Notification](/assets/images/turn.png)

![won](/assets/images/won.png)  ![over](/assets/images/over.png)


### :book: Rules of Chess

If you need a refresher on chess rules, you can visit:
Learn How to Play Chess- `(https://www.chess.com/learn-how-to-play-chess)`

### :point_down: real-time chess 
`(https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExcnIzOHRhNXB2ejRzanN1dzMwcTJ1cTIxZmVjMGluMzRsZXRpeXF5biZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/eg8EPt472uqFbNyAdB/giphy.gif) `
