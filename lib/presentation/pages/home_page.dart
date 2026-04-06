import 'package:flutter/material.dart';
import 'package:smart_univ/core/router/auth_state.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  final AuthState authState;
  const HomePage({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authState.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: const Center(child: Text('Home — coming soon')),
    );
  }
}
