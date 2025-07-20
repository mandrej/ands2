import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/find/cubit/find_cubit.dart';
import 'package:flutter_infinite_list/photo/bloc/photo_bloc.dart';
import 'package:flutter_infinite_list/posts/view/posts_list.dart';
import 'package:flutter_infinite_list/posts/widgets/find_form.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      // drawer: Drawer(
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.only(
      //       topRight: Radius.circular(0),
      //       bottomRight: Radius.circular(0),
      //     ),
      //   ),
      //   child: FindForm(),
      // ),
      body: BlocProvider(
        create:
            (_) => PhotoBloc(context.read<FindCubit>())..add(PhotoFetched()),
        child: Row(
          children: [Expanded(child: FindForm()), Expanded(child: PostsList())],
        ),
      ),
    );
  }
}
