import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/todo_provider.dart';

class TodoTile extends StatelessWidget {
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete; 

  const TodoTile({
    super.key,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    final todo = provider.todos[index];

    return ListTile(
      title: Text(
        todo.todo,
        style: TextStyle(
          decoration: todo.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      leading: Checkbox(
        value: todo.isDone,
        onChanged: (_) => provider.toggleDone(context,index),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
        ],
      ),
    );
  }
}
