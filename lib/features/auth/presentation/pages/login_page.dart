import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import 'package:smart_univ/core/router/auth_state.dart';

class LoginPage extends StatelessWidget {
  final AuthState authState;
  const LoginPage({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 72),
            const SizedBox(height: 24),
            Text('SmartCampus', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 48),
            FilledButton(
              onPressed: () {
                authState.login();
                context.go('/home');
              },
              child: const Text('Sign in (mock)'),
            ),
          ],
        ),
      ),
    );
  }
}
