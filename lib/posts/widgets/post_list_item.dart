import 'package:flutter/material.dart';
// import 'package:flutter_infinite_list/posts/posts.dart';
import 'package:flutter_infinite_list/record/models/record.dart';

class PostListItem extends StatelessWidget {
  const PostListItem({required this.post, super.key});

  final Record post;

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
        child: Image.network(post.thumb, fit: BoxFit.cover),
      ),
      // leading: Text('${post.filename}', style: textTheme.bodySmall),
      title: Text(post.headline),
      isThreeLine: true,
      subtitle: Text(post.filename),
      dense: true,
    );
  }
}
