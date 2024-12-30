import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show immutable;

const _uuid = Uuid();

@immutable
class Todo {
  final String id;
  final String description;
  final bool completed;

  const Todo({
    required this.id,
    required this.description,
    this.completed = false,
  });

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }

  Todo copyWith({id, description, completed}) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
}

class TodoList extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => [
        const Todo(id: 'todo-0', description: 'Pray before going to sleep'),
        const Todo(id: 'todo-1', description: 'Read Exodus book'),
        const Todo(id: 'todo-2', description: 'Tell my wife I love her'),
      ];

  void add(String description) {
    state = [
      ...state,
      Todo(id: _uuid.v4(), description: description),
    ];
  }

  void toggle(String id) {
    state = state
        .map(
          (todo) => todo.id == id
              ? todo.copyWith(
                  completed: !todo.completed,
                )
              : todo,
        )
        .toList();
  }

  void edit({required String id, required String description}) {
    state = state
        .map((todo) =>
            todo.id == id ? todo.copyWith(description: description) : todo)
        .toList();
  }

  void remove(Todo target) {
    state = state.where((todo) => todo.id != target.id).toList();
  }
}
