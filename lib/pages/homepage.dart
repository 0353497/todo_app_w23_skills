import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/models/todo.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final Box db = Hive.box("todos");
  final TextEditingController _controller = TextEditingController();
  bool makingTodo = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TakenLijstje'),
        actions: [
          IconButton(
            onPressed: (){
            final bool isDarkmode = Theme.of(context).brightness == Brightness.dark;
            Hive.box("theme").put("currentTheme", isDarkmode ? "light" : "dark");
          },
          icon:
          Theme.of(context).brightness == Brightness.light ?
          const Icon(Icons.dark_mode) : const Icon(Icons.light_mode)
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
          padding: const EdgeInsets.all(8),
          child: ValueListenableBuilder(
            valueListenable: db.listenable(),
            builder: (context, box, _) {
              if (box.isEmpty) {
                return const Center(
                  child: Text('nog geen taken'),
                );
              }
              
              return ReorderableListView.builder(
                itemBuilder: (context, index) {
                  final Todo todo = box.getAt(index);
                  return Dismissible(
                    key: ValueKey('todo_${index}_${todo.task}'),
                    background: Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.red,
                      child: const Icon(Icons.delete),
                    ),
                    onDismissed: (direction) {
                      box.deleteAt(index);
                    },
                    child: ListTile(
                      key: ValueKey('todo_card_${index}_${todo.task}'),
                      leading: Checkbox(
                        value: todo.isDone,
                        onChanged: (value) {
                          if (value != null) {
                            final Todo newTodo = todo.copyWith(isDone: value);
                            box.putAt(index, newTodo);
                          }
                        },
                      ),
                      title: Text(
                        todo.task,
                        style: TextStyle(
                          decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                    ),
                  );
                },
                itemCount: box.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  List<Todo> updatedTodos = [];
                  for (int i = 0; i < box.length; i++) {
                    updatedTodos.add(box.getAt(i));
                  }
                  final movedTodo = updatedTodos.removeAt(oldIndex);
                  updatedTodos.insert(newIndex, movedTodo);
                  for (int i = 0; i < updatedTodos.length; i++) {
                    box.putAt(i, Todo(
                      isDone: updatedTodos[i].isDone,
                      task: updatedTodos[i].task,
                      index: i,
                    ));
                  }
                },
              );
            }
          ),
        ),
        Positioned(
          left: 20,
          bottom: 80,
          child: GestureDetector(
              child: Text(
                "wis afgevinkte taken",
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.red,
                fontSize: 20,
                decorationColor: Colors.red
              ),
              ),
              onTap: () => deleteFinished(),
            )
          )
        ]
      ),
      bottomSheet: makingTodo ? null : BottomSheet(
        enableDrag: false,
        onClosing: (){},
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => addTask(),
                    onTapOutside: (_) => addTask(),
                    decoration: const InputDecoration(
                      hintText: 'Voeg een nieuwe taak toe',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => addTask(),
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
            ),
          );
        }
      ),
      floatingActionButton: !makingTodo? null : FloatingActionButton(
        onPressed: () => setState(() {
          makingTodo = !makingTodo;
        }),
        shape: CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void addTask() {
    if (_controller.text.isNotEmpty) {
      final newTodo = Todo(
        isDone: false,
        task: _controller.text,
        index: db.length,
      );
      
      db.add(newTodo);
      _controller.clear();
      setState(() {
        makingTodo = !makingTodo;
      });
    }
  }
  
  void deleteFinished() {
    for (int i = db.length - 1; i >= 0; i--) {
      final todo = db.getAt(i) as Todo;
      if (todo.isDone) {
        db.deleteAt(i);
      }
    }
  }
}