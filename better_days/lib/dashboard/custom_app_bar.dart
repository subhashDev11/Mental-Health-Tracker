import 'package:better_days/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;

    return AppBar(
      toolbarHeight: 80,
      leadingWidth: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/logo.png',
            height: 120,
            width: 120,
          ), // Optional logo
          const Spacer(),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, "/profile");
            },
            child: CircleAvatar(
              backgroundImage:
                  user?.profileImage != null
                      ? CachedNetworkImageProvider(user!.profileImage!)
                      : AssetImage('assets/avatar.jpg'),
              radius: 28,
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(80);
}
