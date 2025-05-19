class Task {
  final int id;
  final String title;
  final String? description;
  final String status;
  final DateTime dueDate;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      dueDate: DateTime.parse(json['dueDate']),
    );
  }
}