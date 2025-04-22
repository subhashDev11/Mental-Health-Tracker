import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'app_button.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return AppBar(
      title: const Text('Better days'),
      actions: [
        if (authService.isAuthenticated) ...[
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          AppButton(
            isLoading: authService.isLoading,
            text: 'Sign Out',
            variant: ButtonVariant.outline,
            size: ButtonSize.small,
            onPressed: () {
              authService.logout(context);
            },
          ),
          const SizedBox(width: 8),
        ] else ...[
          AppButton(
            text: 'Sign In',
            isLoading: authService.isLoading,
            variant: ButtonVariant.outline,
            size: ButtonSize.small,
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
          const SizedBox(width: 8),
          AppButton(
            text: 'Sign Up',
            isLoading: authService.isLoading,
            size: ButtonSize.small,
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}