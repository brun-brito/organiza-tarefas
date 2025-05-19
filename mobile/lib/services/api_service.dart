import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));
    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar tarefas');
    }
  }

  static Future<void> addTask(String title, String description, DateTime dueDate) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar tarefa');
    }
  }

  static Future<Task> getTaskById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/tasks/$id'));
    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erro ao buscar tarefa');
    }
  }

  static Future<void> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
        'status': task.status,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar tarefa');
    }
  }

  static Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$id'));
    if (response.statusCode != 204) {
      throw Exception('Erro ao deletar tarefa');
    }
  }
}