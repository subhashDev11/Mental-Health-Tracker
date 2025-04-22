import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../common/app_button.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.indigo[100],
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user?.name ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(user?.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Date of Birth'),
              subtitle: Text(user?.formattedDob ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.height),
              title: const Text('Height'),
              subtitle: Text('${user?.height} cm'),
            ),
            ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: const Text('Weight'),
              subtitle: Text('${user?.weight} kg'),
            ),
            const SizedBox(height: 32),
            Center(
              child: AppButton(
                text: 'Sign Out',
                isLoading: authService.isLoading,
                variant: ButtonVariant.danger,
                onPressed: () {
                  authService.logout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}