import 'package:flutter/material.dart';
import '../photo/models/photo.dart';

class PostListItem extends StatelessWidget {
  const PostListItem({required this.photo, super.key});

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 44,
          minHeight: 44,
          maxWidth: 64,
          maxHeight: 64,
        ),
        child: Image.network(photo.thumb, fit: BoxFit.cover),
      ),
      // leading: Text('${post.filename}', style: textTheme.bodySmall),
      title: Text(photo.headline),
      isThreeLine: true,
      subtitle: Text(photo.filename),
      dense: true,
    );
  }
}
