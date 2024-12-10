import 'package:flutter/material.dart';

class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting Room'),
      ),
      body: const Center(
        child: Text('Welcome to the Waiting Room!'),
      ),
    );
  }
}
