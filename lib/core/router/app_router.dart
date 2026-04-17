import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/groups/presentation/screens/groups_home_screen.dart';

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateStreamProvider);

    return authState.when(
      // Still waiting for Firebase to respond — show a blank dark screen
      // This only lasts ~200ms on first launch
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0A0A0B),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00956E),
            strokeWidth: 2,
          ),
        ),
      ),

      // Firebase responded — route based on user presence
      data: (user) {
        if (user != null) {
          return const GroupsHomeScreen();
        }
        return const AuthScreen();
      },

      // Firebase itself threw an error — show auth screen as safe fallback
      error: (_, __) => const AuthScreen(),
    );
  }
}
