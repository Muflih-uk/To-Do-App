import 'package:flutter/material.dart';
import 'Screens/todo_view.dart';
import 'package:provider/provider.dart';
import 'Providers/todo_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: MaterialApp(
        title: 'To Do',
        debugShowCheckedModeBanner: false,
        home: const TodoView(),
      )
    );
  }
}
