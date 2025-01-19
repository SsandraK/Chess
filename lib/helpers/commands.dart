
import 'package:chess_game/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseDatabase.instance.databaseURL =
          "https://chess-fd8af-default-rtdb.europe-west1.firebasedatabase.app/";
      print('Firebase initialized successfully!');
    } catch (e) {
      print('Firebase initialization failed: $e');
      rethrow; 
    }
  }
}



