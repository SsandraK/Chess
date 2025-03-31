import 'package:chess_game/helpers/commands.dart';
import 'package:chess_game/providers/database_provider.dart';
import 'package:chess_game/providers/game_provider.dart';
import 'package:chess_game/providers/user_provider.dart';
import 'package:chess_game/providers/waitingroom_provider.dart';
import 'package:chess_game/screens/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseService = FirebaseService();
  await firebaseService.initializeFirebase();
   await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => WaitingRoomProvider(
            context.read<DatabaseService>(),
            context.read<UserProvider>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chess App',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: const ColorScheme.highContrastLight(),
        useMaterial3: true,
      ),
      home: const MenuScreen(), 
      builder: (context, widget) {
        return widget ?? const Scaffold(body: Center(child: Text('An error occurred.')));
      },
    );
  }
}
