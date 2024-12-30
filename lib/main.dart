import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_todo_2/old/main.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      // title: 'Material App',
      home: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Material App Bar'),
        // ),
        body: SafeArea(
          child: Column(
            children: [
              Text(
                'What needs to be done?',
                style: textTheme.displaySmall,
              ),
              const TodoPage()
            ],
          ),
        ),
      ),
    );
  }
}

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(todoListProvider);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(data[index].description),
        );
      },
    );
  }
}
