import 'package:flutter/material.dart';
import 'view/home_page.dart';
import 'view/list_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(title: 'Andrejeвићи'),
        '/list': (context) => ListPage(title: 'Andrejeвићи'),
        // '/list': (context) => ListPage(title: 'Andrejeвићи'),
        // '/add': (context) => TaskManager(),
      },
      // home: PostsPage()
    );
  }
}
