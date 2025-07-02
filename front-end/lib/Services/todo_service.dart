import 'package:dio/dio.dart';
import 'package:todo_app/Model/todo_model.dart';
import 'dart:convert';

class TodoService {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
  final String apiKey = 'mufi9605';

  Future<List<TodoModel>> fetchTodos() async {
    final response = await dio.get('/tasks?api_key=$apiKey');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((item) => TodoModel(id: item[0], todo: item[1], isDone: item[2])).toList();
    } else {
      throw Exception('Failed to fetch todos');
    }
  }

  Future<void> postTodo(TodoModel todo) async {
    final requestBody = {
      'task': todo.todo,
      'done': todo.isDone,
    };

    await dio.post(
      '/tasks?api_key=$apiKey',
      data: json.encode(requestBody),
      //options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  Future<void> updateTodo(TodoModel todo) async {
    await dio.put(
      '/tasks/${todo.id}?api_key=$apiKey',
      data: json.encode({
        'task': todo.todo,
        'done': todo.isDone,
      }),
      //options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  Future<void> deleteTodo(int id) async {
    await dio.delete('/tasks/$id?api_key=$apiKey');
  }
}
