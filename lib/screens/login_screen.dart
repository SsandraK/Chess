import 'package:chess_game/providers/user_provider.dart';
import 'package:chess_game/screens/waiting_room_screen.dart';
import 'package:chess_game/widgets/menucard_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final dynamic username;

  const LoginScreen({super.key, required this.username});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameInputController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Welcome to Chess'),
        backgroundColor: const Color.fromARGB(255, 105, 203, 252),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: BackgroundWidget(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 6.0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.chessKing,
                    size: 100.0,
                    color:  Color.fromARGB(255, 219, 237, 246),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Log in to Play Chess!',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Username Input Form
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _usernameInputController,
                      decoration: InputDecoration(
                        hintText: 'Enter your username',
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.account_circle),
                      ),
                      validator: (value) {
                        final RegExp usernamePattern =
                            RegExp(r'^[a-zA-Z0-9]+$');
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        if (!usernamePattern.hasMatch(value.trim())) {
                          return 'Username must contain only letters and numbers';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  if (userProvider.isRegistering)
                    const CircularProgressIndicator()
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final String username =
                                _usernameInputController.text.trim();
                            print('Attempting to log in user: $username');

                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);
                            await userProvider.addUser(username);
                            await userProvider.loginUser(username);
                            print('loginUser completed.');

                            if (!mounted) return;
                            if (userProvider.errorMessage != null) {
                              print(
                                  'Error during login: ${userProvider.errorMessage}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(userProvider.errorMessage!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else if (userProvider.hasUser) {
                              print('Login successful for user: $username');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Login Successful!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WaitingRoomScreen(
                                    username: username,
                                  ),
                                ),
                              );
                            } else {
                              print('Unexpected error: User not logged in.');
                            }
                          } else {
                            print('Validation failed: Username is invalid.');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 219, 237, 246),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
