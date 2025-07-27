import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../photo/bloc/photo_bloc.dart';
import '../photo/models/photo.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({super.key, required this.record});
  final Photo record;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PhotoBloc>(
      create: (context) => PhotoBloc(),
      child: Builder(
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(16),
            title: const Text('Delete'),
            content: Text(
              'Are you sure you want to delete ${record.headline}?',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Delete'),
                onPressed: () {
                  context.read<PhotoBloc>().add(PhotoDelete(record.filename));
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
