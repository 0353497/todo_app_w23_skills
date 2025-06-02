import 'package:hive/hive.dart';
part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  final bool isDone;

  @HiveField(1)
  final String task;

  @HiveField(2)
  final int index;

  Todo({required this.isDone, required this.task, required this.index});

  Todo copyWith({bool? isDone, String? task, int? index}) {
    return Todo(
      isDone: isDone ?? this.isDone,
      task: task ?? this.task,
      index: index ?? this.index,
    );
  }
}