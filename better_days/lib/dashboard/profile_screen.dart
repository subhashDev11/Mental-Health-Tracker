import 'package:better_days/dashboard/edit_profile.dart';
import 'package:better_days/models/user.dart';
import 'package:better_days/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:snacknload/snacknload.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthService>().user;

    if (user == null) {
      return SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => EditProfileScreen(
                        currentName: user.name,
                        currentEmail: user.email,
                        currentDob: user.dob,
                        currentHeight: user.height,
                        currentWeight: user.weight,
                        currentProfileImage: user.profileImage,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context, user),
            const SizedBox(height: 24),

            // Personal Information Section
            _buildSectionHeader(theme, 'Personal Information'),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              children: [
                _buildInfoRow(theme, Icons.person, 'Name', user.name),
                _buildInfoRow(theme, Icons.email, 'Email', user.email),
                _buildInfoRow(
                  theme,
                  Icons.cake,
                  'Date of Birth',
                  DateFormat('MMMM d, y').format(user.dob),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Health Information Section
            _buildSectionHeader(theme, 'Health Information'),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              children: [
                if (user.height != null)
                  _buildInfoRow(
                    theme,
                    Icons.height,
                    'Height',
                    '${user.height?.toStringAsFixed(1)} cm',
                  ),
                if (user.weight != null)
                  _buildInfoRow(
                    theme,
                    Icons.monitor_weight,
                    'Weight',
                    '${user.weight?.toStringAsFixed(1)} kg',
                  ),
                if (user.weight != null && user.height != null)
                  _buildInfoRow(
                    theme,
                    Icons.calculate,
                    'BMI',
                    _calculateBMI(
                      user.height!,
                      user.weight!,
                    ).toStringAsFixed(1),
                  ),
              ],
            ),
            const SizedBox(height: 32),

            // Account Actions
            _buildSectionHeader(theme, 'Account'),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showLogoutConfirmation(context);
                    },
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.red,
                    ),
                    onTap: () {
                      _showDeleteConfirmation(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    final theme = Theme.of(context);
    final age = DateTime.now().difference(user.dob).inDays ~/ 365;

    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          backgroundImage:
              user.profileImage != null
                  ? CachedNetworkImageProvider(user.profileImage!)
                  : null,
          child:
              (user.profileImage == null)
                  ? Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$age years',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateBMI(double height, double weight) {
    // BMI formula: weight (kg) / (height (m))^2
    return weight / ((height / 100) * (height / 100));
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthService>().logout(context);
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String? reason;
        return AlertDialog(
          title: const Text('Delete account'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Text("Are you sure you want to delete account?"),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter the reason",
                ),
                onChanged: (v) {
                  reason = v;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (reason == null || reason!.isEmpty) {
                  SnackNLoad.showSnackBar(
                    "Please enter the reason of deleting account",
                    type: Type.info,
                  );
                  return;
                }
                Navigator.pop(context);
                final authService = context.read<AuthService>();
                bool deleted = await authService.deleteAccount(
                  reason: reason!,
                );
                if(deleted){
                  authService.logout(context);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
