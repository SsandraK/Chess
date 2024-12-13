import 'package:chess/providers/user_provider.dart';
import 'package:chess/screens/waiting_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  bool checkPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: const Color.fromARGB(255, 199, 227, 199),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          color: const Color.fromARGB(255, 241, 245, 241),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.login_outlined,
                    size: 80,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please log in to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(136, 60, 59, 59),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 25,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.account_box),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username!';
                      } else if (value.length < 4) {
                        return 'Username must be at least 4 characters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      username = value.trim();
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    maxLength: 25,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password!';
                      } else if (value.length < 7) {
                        return 'Password must be at least 7 characters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        password = value.trim();
                        checkPassword = password.isNotEmpty;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);

                        try {
                          // Check if username already exists
                          final userExists =
                              await userProvider.checkIfUserExists(username);
                          if (userExists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Username is already in use!')),
                            );
                            return; // Prevent the user from proceeding
                          }

                          // Save user data and proceed to the waiting room
                          await userProvider.saveUser(
                              username: username, password: password);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WaitingRoomScreen(
                                      username: username,
                                    )),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed to join the waiting room: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
