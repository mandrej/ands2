import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/find/cubit/find_cubit.dart';
import 'package:flutter_infinite_list/view/home_page.dart';
// import 'package:flutter_infinite_list/posts/view/posts_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FindCubit(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(title: 'Andrejeвићи'),
          // '/list': (context) => ListPage(title: 'Andrejeвићи'),
          // '/add': (context) => TaskManager(),
        },
        // home: PostsPage()
      ),
    );
  }
}
