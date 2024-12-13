import 'package:chess/providers/game_provider.dart';
import 'package:chess/screens/game_screen.dart';
import 'package:chess/screens/login_screen.dart';
import 'package:chess/widgets/menucard_widget.dart';
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
      backgroundColor: const Color.fromARGB(255, 199, 227, 199),
      title: const Text('Menu'),
       centerTitle: true,
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
        children: [
        MenuCard(
            icon: Icons.computer,
            label: 'Play vs Computer',
            onTap: () {
              gameProvider.setVsComputer(value: true);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GameScreen()),
              );
            },
          ),
          MenuCard(
            icon: Icons.people,
            label: 'Play with Friend',
            onTap: () {
              gameProvider.setVsComputer(value: false);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    ),
  );
}
}