import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/todo_model.dart';

class TodoController {
  // Load from local storage
  Future<List<TodoModel>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('todos');
    if (jsonString == null) return [];

    final List decodedList = json.decode(jsonString);
    return decodedList.map((e) => TodoModel.fromJson(e)).toList();
  }

  // Save to local storage
  Future<void> saveTodos(List<TodoModel> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(todos.map((e) => e.toJson()).toList());
    await prefs.setString('todos', data);
  }
}
