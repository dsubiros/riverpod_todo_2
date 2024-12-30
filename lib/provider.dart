import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_todo_2/todo.dart';

/// Some keys used for testing
final addTodoKey = UniqueKey();
final activeFilterKey = UniqueKey();
final completedFilterKey = UniqueKey();
final allFilterKey = UniqueKey();

/// Creates a [TodoList] and init it with pre-defined values.
///
/// We are using [StateNotifierProvider] here as a `List<Todo>` is a complex
/// object, width advanced business logic like how to edit a todo.
final todoListProvider = NotifierProvider<TodoList, List<Todo>>(TodoList.new);

/// The different ways to filter the list of todos
enum TodoListFilter {
  all,
  active,
  completed,
}

/// The currently active filter.
///
/// We use [StateProvider] here as there is no fancy logic behind manipulating
/// the value since it's just enum.
final todoListFilter = StateProvider((_) => TodoListFilter.all);

/// The number of uncompleted todos.
///
/// By using [Provider], this value is cached, making it performant.\
/// Even if multiple widgets try to read the number of uncompleted todos,
/// the value will computed only once (until the todo-list changes).
///
/// This will also optimize unneeded rebuilds if the todo-list changes, but the
/// number of uncompleted todos doesn't (such as when editing a todo).
final uncompletedTodosCount = Provider<int>((ref) =>
    ref.watch(todoListProvider).where((item) => !item.completed).length);

/// The list of todos after applying if [todoListFilter]
///
/// This too uses [Provider], to avoid recomputing the filtered list unless
/// either the filter if or the todo-list updates.
final filteredTodos = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoListFilter);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoListFilter.active:
      return todos.where((todo) => !todo.completed).toList();

    case TodoListFilter.completed:
      return todos.where((todo) => todo.completed).toList();

    case TodoListFilter.all:
      return todos;
  }
});
