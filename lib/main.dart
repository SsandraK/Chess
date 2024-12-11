import 'package:chess/firebase_options.dart';
import 'package:chess/providers/game_provider.dart';
import 'package:chess/providers/user_provider.dart';
import 'package:chess/providers/waitingroom_provider.dart';
import 'package:chess/screens/menu_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(

    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WaitingRoomProvider()),
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

