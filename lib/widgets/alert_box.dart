import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget {
  const AlertBox({super.key, required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // contentPadding: EdgeInsets.all(16),
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(children: [Text(content)]),
      ),
      // actions: <Widget>[
      //   ElevatedButton(
      //     child: const Text('Ok'),
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //   ),
      // ],
    );
  }
}
