import 'package:chess/screens/game_screen.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 224, 246, 157),
        title: const Text('Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0), 
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 1, 
          mainAxisSpacing: 16.0, // Space between rows
          crossAxisSpacing: 16.0, // Space between columns
          children: [
            Card(
              color: const Color.fromARGB(255, 241, 245, 241),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.computer),
                    SizedBox(height: 10),
                    Text('Play vs Computer'),
                  ],
                ),
              ),
            ),
            Card(
              color: const Color.fromARGB(255, 241, 245, 241),
              child: InkWell(
                onTap: () {
                  // Navigate to another screen
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const FriendGameScreen()),
                  // );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people),
                    SizedBox(height: 10),
                    Text('Play with Friend'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
