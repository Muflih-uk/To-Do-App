class TodoModel {
  int id;
  String todo;
  bool isDone;

  TodoModel({
    required this.id,
    required this.todo,
    required this.isDone,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      todo: json['todo'],
      isDone: json['isDone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todo': todo,
      'done': isDone,
    };
  }
}
