import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/user_bloc.dart';

class EditView extends StatelessWidget {
  const EditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state.isAdmin || state.isFamily) {
            return TextButton(
              onPressed: () => context.read<UserBloc>().add(UserEdit()),
              child: Text(
                state.isEditing ? 'EDIT MODE' : 'VIEW MODE',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
