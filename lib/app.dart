import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_infinite_list/find/cubit/find_cubit.dart';
import 'package:flutter_infinite_list/photo/bloc/photo_bloc.dart';
import 'view/home_page.dart';
import 'view/list_page.dart';
// import 'examples/auto_suggest_multi_field_example.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(title: 'Andrejeвићи'),
        '/list':
            (context) => BlocProvider<FindCubit>(
              create: (context) => FindCubit(),
              child: BlocProvider<PhotoBloc>(
                create:
                    (context) =>
                        PhotoBloc()..add(
                          PhotoFetched(
                            findState: context.read<FindCubit>().state,
                          ),
                        ),
                child: ListPage(title: 'Andrejeвићи'),
              ),
            ),
        // '/add': (context) => TaskManager(),
        // '/examples/auto_suggest_multi_field':
        //     (context) => AutoSuggestMultiFieldExample(),
        // '/list': (context) => ListPage(title: 'Andrejeвићи'),
      },
      // home: PostsPage()
    );
  }
}
