import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/user_bloc.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return Column(
          children: [
            _SidebarItem(
              icon: Icons.home,
              label: 'Home',
              onTap: () => Navigator.pushNamed(context, '/'),
            ),
            state is UserAuthenticated && state.isFamily
                ? _SidebarItem(
                  icon: Icons.add,
                  label: 'Add',
                  onTap: () => Navigator.pushNamed(context, '/add'),
                )
                : SizedBox.shrink(),
            state is UserAuthenticated && state.isAdmin
                ? _SidebarItem(
                  icon: Icons.settings,
                  label: 'Admin',
                  onTap: () => Navigator.pushNamed(context, '/admin'),
                )
                : SizedBox.shrink(),
          ],
        );
      },
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
      title: Text(
        label,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
      onTap: onTap,
      // dense: true,
    );
  }
}
