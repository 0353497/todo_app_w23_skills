import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/pages/homepage.dart';

void main() async {
  await Hive.initFlutter();
  
  Hive.registerAdapter(TodoAdapter());
  
  await Hive.openBox('todos');
  await Hive.openBox('theme');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('theme').listenable(),
      builder: (context, box, widget) {
        final isDark = box.get('currentTheme', defaultValue: 'light') == 'dark';
        
        return MaterialApp(
          title: 'Todo App',
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            colorSchemeSeed: Colors.red
          ),
          home: const Homepage(),
        );
      }
    );
  }
}
