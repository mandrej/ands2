import 'package:flutter/material.dart';
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
        '/list': (context) => ListPage(title: 'Andrejeвићи'),
        // '/add': (context) => TaskManager(),
        // '/examples/auto_suggest_multi_field':
        //     (context) => AutoSuggestMultiFieldExample(),
        // '/list': (context) => ListPage(title: 'Andrejeвићи'),
      },
      // home: PostsPage()
    );
  }
}
