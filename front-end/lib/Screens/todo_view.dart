import 'package:flutter/material.dart';
import 'package:todo_app/Model/todo_model.dart';
import 'package:todo_app/Screens/Widgets/add_task_dialog.dart';
import 'package:todo_app/Screens/Widgets/todo_tile.dart';
import 'package:provider/provider.dart';
import '../Providers/todo_provider.dart';

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final TextEditingController taskController = TextEditingController();

  void addTask(BuildContext context) {
    taskController.clear();
    showAddOrEditDialog(
      context: context,
      taskController: taskController,
      title: 'Add Task',
      onConfirm: () {
        final todo = TodoModel(
          id: 0, 
          todo: taskController.text,
          isDone: false,
        );
        Provider.of<TodoProvider>(context, listen: false)
            .postTodo(context, todo);
      },
    );
  }

  void editTask(BuildContext context, int index) {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    taskController.text = provider.todos[index].todo;
    showAddOrEditDialog(
      context: context,
      taskController: taskController,
      title: 'Edit Task',
      onConfirm: () {
        final todo = TodoModel(
          id: provider.todos[index].id, 
          todo: taskController.text,
          isDone: provider.todos[index].isDone, 
        );
        provider.updateTodoById(context, todo, index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do List'),
        actions: [
          if (provider.todos.isNotEmpty && provider.deleteEveryTodo())
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => provider.clearAll(context),
            ),
          if (provider.todos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.checklist_rounded),
              onPressed: () => provider.toggleAllDone(context),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: provider.todos.length,
        itemBuilder: (_, index) {
          return TodoTile(
            index: index,
            onEdit: () => editTask(context, index),
            onDelete: () => provider.deleteTodo(context, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}