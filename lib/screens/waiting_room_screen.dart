import 'dart:math';
import 'package:chess/providers/waitingroom_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class WaitingRoomScreen extends StatefulWidget {
  final String username;

  const WaitingRoomScreen({super.key, required this.username});

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  @override
  void initState() {
    super.initState();

    // Join the waiting room and start listening for updates
    final waitingRoomProvider = Provider.of<WaitingRoomProvider>(context, listen: false);
    waitingRoomProvider.joinWaitingRoom(widget.username);
    waitingRoomProvider.fetchWaitingUsers();
  }

  @override
  void dispose() {
    // Leave the waiting room when the screen is closed
    final waitingRoomProvider = Provider.of<WaitingRoomProvider>(context, listen: false);
    waitingRoomProvider.leaveWaitingRoom(widget.username);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waitingRoomProvider = Provider.of<WaitingRoomProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting Room'),
        backgroundColor: const Color.fromARGB(255, 199, 227, 199),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 217, 230, 217),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: Stack(
          children: [
            ..._generateRandomCircles(
              waitingRoomProvider.waitingUsers,
              MediaQuery.of(context).size,
            ),
          ],
        ),
      ),
    );
  }

  // Method to generate random circles
  List<Widget> _generateRandomCircles(
      List<Map<String, dynamic>> users, Size screenSize) {
    final List<Widget> circles = [];
    final random = Random();

    for (var user in users) {
      final double left = random.nextDouble() * (screenSize.width - 100); // Random x-position
      final double top = random.nextDouble() * (screenSize.height - 100); // Random y-position

      circles.add(
        Positioned(
          left: left,
          top: top,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withOpacity(0.7),
            ),
            child: Center(
              child: Text(
                user['username'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return circles;
  }
}
