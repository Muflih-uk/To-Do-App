
import 'package:flutter/material.dart';
import 'package:todo_app/Controller/todo_controller.dart';
import 'package:todo_app/Model/todo_model.dart';
import 'package:todo_app/Services/todo_service.dart';

class TodoProvider extends ChangeNotifier {
  final TodoService _service = TodoService();
  final TodoController _controller = TodoController();
  List<TodoModel> todos = [];

  TodoProvider() {
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      todos = await _service.fetchTodos();
      _controller.saveTodos(todos);
    } catch (e) {
      print("API fetch failed, loading from local: $e");
      todos = await _controller.loadTodos();
    }
    notifyListeners();
  }

  Future<void> postTodo(BuildContext context, TodoModel todo) async {
    try {
      await _service.postTodo(todo);
      await loadTodos();
    } catch (e) {
      _showError(context, "Error adding todo: $e");
    }
  }

  Future<void> updateTodoById(BuildContext context, TodoModel todo, int index) async {
    try {
      final todoToUpdate = todos[index];
      final updatedTodo = TodoModel(id: todoToUpdate.id, todo: todo.todo, isDone: todo.isDone);
      await _service.updateTodo(updatedTodo);
      todos[index] = updatedTodo;
      _controller.saveTodos(todos);
      notifyListeners();
    } catch (e) {
      _showError(context, "Error updating todo: $e");
    }
  }

  Future<void> deleteTodo(BuildContext context, int index) async {
    try {
      final todoToDelete = todos[index];
      await _service.deleteTodo(todoToDelete.id);
      todos.removeAt(index);
      _controller.saveTodos(todos);
      notifyListeners();
    } catch (e) {
      _showError(context, "Error deleting todo: $e");
    }
  }

  Future<void> toggleDone(BuildContext context, int index) async {
    final todo = todos[index];
    final originalState = todo.isDone;
    todo.isDone = !originalState;
    notifyListeners();

    try {
      await _service.updateTodo(todo);
      _controller.saveTodos(todos);
    } catch (e) {
      todo.isDone = originalState;
      notifyListeners();
      _showError(context, "Error toggling task: $e");
    }
  }

  Future<void> clearAll(BuildContext context) async {
    final originalTodos = List<TodoModel>.from(todos);
    List<TodoModel> failedDeletes = [];

    todos.clear();
    notifyListeners();

    for (var todo in originalTodos) {
      try {
        await _service.deleteTodo(todo.id);
      } catch (_) {
        failedDeletes.add(todo);
      }
    }

    if (failedDeletes.isNotEmpty) {
      todos = failedDeletes;
      notifyListeners();
      _showError(context, "Failed to delete ${failedDeletes.length} tasks");
    }

    _controller.saveTodos(todos);
  }

  Future<void> toggleAllDone(BuildContext context) async {
    final allDone = todos.every((todo) => todo.isDone);
    final originalStates = todos.map((t) => t.isDone).toList();
    List<int> failed = [];

    for (var t in todos) {
      t.isDone = !allDone;
    }
    notifyListeners();

    for (int i = 0; i < todos.length; i++) {
      try {
        await _service.updateTodo(todos[i]);
      } catch (_) {
        failed.add(i);
      }
    }

    for (int i in failed) {
      todos[i].isDone = originalStates[i];
    }

    if (failed.isNotEmpty) {
      notifyListeners();
      _showError(context, "Failed to update ${failed.length} tasks");
    }

    _controller.saveTodos(todos);
  }

  bool deleteEveryTodo() {
    return todos.every((todo) => todo.isDone);
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
