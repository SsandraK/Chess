import 'dart:async';

import 'package:chess/providers/user_provider.dart';
import 'package:chess/providers/waitingroom_provider.dart';
import 'package:chess/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String username;

  const WaitingRoomScreen({super.key, required this.username});

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen>
    with WidgetsBindingObserver {
  StreamSubscription? _invitationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Join the waiting room and start fetching users
    final waitingRoomProvider =
        Provider.of<WaitingRoomProvider>(context, listen: false);
    waitingRoomProvider.joinWaitingRoom(widget.username);
    waitingRoomProvider.fetchWaitingUsers();

    // Start listening to game invitations
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _invitationSubscription =
        userProvider.listenToGameInvitations(context, widget.username);
  }

  @override
  void dispose() {
    // Leave the waiting room when the screen is closed
    final waitingRoomProvider =
        Provider.of<WaitingRoomProvider>(context, listen: false);
    waitingRoomProvider.leaveWaitingRoom(widget.username);

    // Cancel the invitation subscription
    _invitationSubscription?.cancel();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final waitingRoomProvider =
        Provider.of<WaitingRoomProvider>(context, listen: false);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      waitingRoomProvider.leaveWaitingRoom(widget.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    final waitingRoomProvider = Provider.of<WaitingRoomProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting Room'),
        backgroundColor: const Color.fromARGB(255, 199, 227, 199),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go to Menu',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MenuScreen()),
              );
            },
          ),
        ],
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
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'Active Users:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: waitingRoomProvider.waitingUsers.isEmpty
                  ? const Center(child: Text('No active users.'))
                  : ListView.builder(
                      itemCount: waitingRoomProvider.waitingUsers.length,
                      itemBuilder: (context, index) {
                        final user = waitingRoomProvider.waitingUsers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 248, 250, 249),
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  user['username'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                // Invite Button (hidden for the current user)
                                user['username'] == widget.username
                                    ? const SizedBox
                                        .shrink() 
                                    : IconButton(
                                        icon: const Icon(Icons.person_add),
                                        onPressed: () {
                                          final waitingRoomProvider =
                                              Provider.of<WaitingRoomProvider>(
                                                  context,
                                                  listen: false);
                                          waitingRoomProvider
                                              .sendGameNotification(
                                                  context,
                                                  widget.username,
                                                  user['username']);
                                        },
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
