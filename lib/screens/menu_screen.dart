import 'package:chess_game/screens/login_screen.dart';
import 'package:chess_game/widgets/menucard_widget.dart';
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
        backgroundColor: const Color.fromARGB(255, 105, 203, 252),
        title: const Text('Menu'),
        centerTitle: true,
      ),
      body: BackgroundWidget(child:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
  
            MenuCard(
              icon: Icons.people,
              label: 'Play with Friend',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(username: null,),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      )
    );
  }
}
