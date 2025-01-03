import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_todo_2/provider.dart';
import 'package:riverpod_todo_2/todo.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Riverpod Todos',
      home: Home(),
    );
  }
}

class Home extends HookConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodos);
    final newTodoController = useTextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            const Tile(),
            TextField(
              key: addTodoKey,
              controller: newTodoController,
              decoration:
                  const InputDecoration(labelText: 'What needs to be done?'),
              onSubmitted: (value) {
                ref.read(todoListProvider.notifier).add(value);
                newTodoController.clear();
              },
            ),
            const SizedBox(height: 42.0),
            const Toolbar(),
            const SizedBox(height: 10.0),
            ...todos.map(
              (todo) => Dismissible(
                key: ValueKey(todo.id),
                onDismissed: (direction) =>
                    ref.read(todoListProvider.notifier).remove(todo),
                // child: ListTile(title: Text(todo.description)),
                child: ProviderScope(
                    overrides: [_currentTodo.overrideWithValue(todo)],
                    child: const TodoItem()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Toolbar extends HookConsumerWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(todoListFilter);

    Color? textColorFor(TodoListFilter value) {
      return filter == value ? Colors.blue : Colors.black;
    }

    return Material(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text('${ref.watch(uncompletedTodosCount)} items left')),
        ToolbarItem(
          tooltipText: 'All',
          filter: TodoListFilter.all,
          onTap: () =>
              ref.watch(todoListFilter.notifier).state = TodoListFilter.all,
          textColor: textColorFor(TodoListFilter.all),
        ),
        ToolbarItem(
          tooltipText: 'Active',
          filter: TodoListFilter.active,
          onTap: () =>
              ref.watch(todoListFilter.notifier).state = TodoListFilter.active,
          textColor: textColorFor(TodoListFilter.active),
        ),
        ToolbarItem(
          tooltipText: 'Complete',
          filter: TodoListFilter.completed,
          onTap: () => ref.watch(todoListFilter.notifier).state =
              TodoListFilter.completed,
          textColor: textColorFor(TodoListFilter.completed),
        ),
      ],
    ));
  }
}

class ToolbarItem extends ConsumerWidget {
  final TodoListFilter filter;
  final String tooltipText;
  final VoidCallback? onTap;
  final Color? textColor;

  const ToolbarItem({
    super.key,
    required this.filter,
    required this.tooltipText,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: tooltipText,
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(textColor)),
        child: Text(tooltipText),
      ),
    );
  }
}

/// A provider which exposes the [Todo] displayed by a [TodoItem].
///
/// By retrieving the [Todo] through a provider instead of through its
/// constructor, this allows [TodoItem] to be instantiated using the `const` keyword.
///
/// This ensures that when we add/remove/edit todos, only what the
/// impacted widgets rebuilds, instead of the entire list of items.
final _currentTodo = Provider<Todo>((ref) => throw UnimplementedError());

class TodoItem extends HookConsumerWidget {
  const TodoItem({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);
    final itemFocusNode = useFocusNode();
    final itemIsFocused = useIsFocused(itemFocusNode);

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    return Material(
      color: Colors.white,
      elevation: 6,
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (focus) {
          if (focus) {
            textEditingController.text = todo.description;
          } else {
            // Commit changes only when the textfield is unfocused, for performance
            ref
                .read(todoListProvider.notifier)
                .edit(id: todo.id, description: textEditingController.text);
          }
        },
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          leading: Checkbox(
              value: todo.completed,
              onChanged: (value) =>
                  ref.read(todoListProvider.notifier).toggle(todo.id)),
          title: itemIsFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(todo.description),
        ),
      ),
    );
  }
}

bool useIsFocused(FocusNode node) {
  final isFocused = useState(node.hasFocus);

  useEffect(() {
    void listener() {
      isFocused.value = node.hasFocus;
    }

    node.addListener(listener);
    return () => node.removeListener(listener);
  }, [node]);

  return isFocused.value;
}

class Tile extends StatelessWidget {
  const Tile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'todos',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.orange,
        fontSize: 100,
        fontWeight: FontWeight.w100,
        fontFamily: 'Helvetica Neue',
      ),
    );
  }
}

// class TodoPage extends HookConsumerWidget {
//   const TodoPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final data = ref.watch(filteredTodos);

//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: data.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text(data[index].description),
//         );
//       },
//     );
//   }
// }
