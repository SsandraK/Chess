import 'package:chess/providers/game_provider.dart';
import 'package:chess/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
  
        colorScheme:const ColorScheme.highContrastLight(),
        useMaterial3: true,
      ),
      home:const MenuScreen(),
    );
  }
}

