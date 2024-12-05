import 'package:chess/providers/game_provider.dart';
import 'package:chess/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
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
          mainAxisSpacing: 16.0, 
          crossAxisSpacing: 16.0, 
          children: [
            Card(
              color: const Color.fromARGB(255, 241, 245, 241),
              child: InkWell(
                onTap: () {
                  gameProvider.setVsComputer(value: true);
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
                 gameProvider.setVsComputer(value: false);
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
