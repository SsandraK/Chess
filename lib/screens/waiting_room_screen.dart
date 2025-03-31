import 'package:chess_game/helpers/game.dart';
import 'package:chess_game/helpers/waitingroom.dart';
import 'package:chess_game/providers/database_provider.dart';
import 'package:chess_game/providers/user_provider.dart';
import 'package:chess_game/providers/waitingroom_provider.dart';
import 'package:chess_game/screens/game_screen.dart';
import 'package:chess_game/widgets/menucard_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bishop/bishop.dart' as bishop;

class WaitingRoomScreen extends StatefulWidget {
  final String username;

  const WaitingRoomScreen({super.key, required this.username});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _initializeRoom);
  }

  Future<void> _initializeRoom() async {
    final waitingRoomProvider =
        Provider.of<WaitingRoomProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user != null) {
      final owner = userProvider.user!.copyWith(isWhite: true);
      final newRoom = WaitingRoom(
        owner: owner,
        guest: null,
        roomId: 'room-id',
      );
      await waitingRoomProvider.createRoom(newRoom);
    }
  }

  void _showSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final waitingRoomProvider = Provider.of<WaitingRoomProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentRoom = waitingRoomProvider.currentRoom;

    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('Waiting Room'),
        backgroundColor: const Color.fromARGB(255, 141, 211, 245),
        centerTitle: true,
      ),
      body: BackgroundWidget(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (context) {
                if (waitingRoomProvider.isLoading) {
                  return const CircularProgressIndicator();
                }
                if (currentRoom == null) {
                  return const Center(
                    child: Text(
                      'No room available.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }
                final isHost =
                    currentRoom.owner.uuid == userProvider.user?.uuid;

                return Card(
                  elevation: 8.0,
                  color: const Color.fromARGB(255, 219, 237, 246),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Room Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/user.png'),
                          ),
                          title: Text(
                            currentRoom.owner.uuid == userProvider.user?.uuid
                                ? 'Hei! ${currentRoom.owner.username}'
                                : 'Player: ${currentRoom.owner.username}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/user01.png'),
                          ),
                          title: Text(
                            currentRoom.guest == null
                                ? 'Waiting for other player...'
                                : (currentRoom.guest!.uuid ==
                                        userProvider.user?.uuid
                                    ? 'Hei! ${currentRoom.guest!.username}'
                                    : 'Player: ${currentRoom.guest!.username}'),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!isHost && currentRoom.guest == null)
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await waitingRoomProvider.joinRoom(
                                  currentRoom.roomId,
                                  userProvider.user!,
                                );
                              } catch (e) {
                                _showSnackBar('Error joining room: $e');
                              }
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Start game'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 105, 203, 252),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 12.0,
                              ),
                            ),
                          ),
                        if (currentRoom.guest != null && isHost)
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final dbService = Provider.of<DatabaseService>(
                                    context,
                                    listen: false);
                                final updatedRoom = await dbService
                                    .fetchWaitingRoom(currentRoom.roomId);

                                if (updatedRoom == null ||
                                    updatedRoom.guest == null) {
                                  _showSnackBar(
                                    'Room is not ready to start. Please wait for a guest to join.',
                                  );
                                  return;
                                }

                                final gameId = updatedRoom.roomId;
                                final newGame = GameModel(
                                  players: {
                                    'white': updatedRoom.owner,
                                    'black': updatedRoom.guest!,
                                  },
                                  status: 'in-game',
                                  currentMove: 'white',
                                  fen: bishop.Game(
                                          variant: bishop.Variant.standard())
                                      .fen,
                                  gameId: gameId,
                                );
                                await dbService.saveGame(gameId, newGame);

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GameScreen(
                                      roomId: updatedRoom,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                _showSnackBar('Error starting game: $e');
                              }
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Game'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 129, 172, 219),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 12.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
