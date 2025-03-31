
import 'package:chess_game/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

 Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseDatabase.instance.databaseURL = dotenv.env['DATABASE_URL']!;
      print('Firebase initialized successfully!');
    } catch (e) {
      print('Firebase initialization failed: $e');
      rethrow;
    }
  }
}



