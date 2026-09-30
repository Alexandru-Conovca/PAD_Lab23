import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.nights_stay, size: 54, color: scheme.primary),
                const SizedBox(height: 24),
                Text('Welcome to Polaris', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Your calm, curious companion for every clear night.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 36),
                const TextField(decoration: InputDecoration(labelText: 'Email or username', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
                const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onLogin, icon: const Icon(Icons.arrow_forward), label: const Text('Войти'))),
                Center(child: TextButton(onPressed: () {}, child: const Text('Нет аккаунта? Зарегистрируйтесь'))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}