import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../screens/add_task_screen.dart';

enum TaskFilter { all, pending, done }
enum TaskPeriod { today, week, month }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Task>> _tasksFuture;
  TaskFilter _filter = TaskFilter.all;
  TaskPeriod _period = TaskPeriod.today;
  DateTime _periodAnchor = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    _tasksFuture = ApiService.fetchTasks();
  }

  void _toggleStatus(Task task) async {
    final updated = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      status: task.status == 'done' ? 'pending' : 'done',
    );
    await ApiService.updateTask(updated);
    setState(_loadTasks);
  }

  DateTime _addPeriod(DateTime date, TaskPeriod period) {
    switch (period) {
      case TaskPeriod.today:
        return date.add(Duration(days: 1));
      case TaskPeriod.week:
        return date.add(Duration(days: 7));
      case TaskPeriod.month:
        return DateTime(date.year, date.month + 1, date.day);
    }
  }

  DateTime _subtractPeriod(DateTime date, TaskPeriod period) {
    switch (period) {
      case TaskPeriod.today:
        return date.subtract(Duration(days: 1));
      case TaskPeriod.week:
        return date.subtract(Duration(days: 7));
      case TaskPeriod.month:
        return DateTime(date.year, date.month - 1, date.day);
    }
  }

  String _periodLabel() {
    switch (_period) {
      case TaskPeriod.today:
        return 'Dia: ${_formatDate(_periodAnchor)}';
      case TaskPeriod.week:
        final end = _periodAnchor.add(Duration(days: 6));
        return 'Semana: ${_formatDate(_periodAnchor)} - ${_formatDate(end)}';
      case TaskPeriod.month:
        return 'Mês: ${_periodAnchor.month}/${_periodAnchor.year}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minhas Tarefas')),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final tasks = snapshot.data!;
          final filteredTasks = tasks.where((t) {
            if (_filter == TaskFilter.pending && t.status != 'pending') return false;
            if (_filter == TaskFilter.done && t.status != 'done') return false;

            final date = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
            final anchor = DateTime(_periodAnchor.year, _periodAnchor.month, _periodAnchor.day);

            switch (_period) {
              case TaskPeriod.today:
                return date == anchor;
              case TaskPeriod.week:
                final start = anchor;
                final end = anchor.add(Duration(days: 6));
                return date.isAtSameMomentAs(start) || (date.isAfter(start) && date.isBefore(end)) || date.isAtSameMomentAs(end);
              case TaskPeriod.month:
                return date.month == anchor.month && date.year == anchor.year;
            }
          }).toList();

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _periodAnchor = _subtractPeriod(_periodAnchor, _period);
                      });
                    },
                  ),
                  Text(_periodLabel()),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      setState(() {
                        _periodAnchor = _addPeriod(_periodAnchor, _period);
                      });
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ToggleButtons(
                  isSelected: TaskPeriod.values.map((p) => p == _period).toList(),
                  onPressed: (index) {
                    setState(() {
                      _period = TaskPeriod.values[index];
                    });
                  },
                  children: [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Hoje')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Semana')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Mês')),
                  ],
                ),
              ),
              
              filteredTasks.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Text(() {
                          switch (_filter) {
                            case TaskFilter.pending:
                              return 'Nenhuma tarefa pendente.';
                            case TaskFilter.done:
                              return 'Nenhuma tarefa concluída.';
                            default:
                              return 'Nenhuma tarefa encontrada.';
                          }
                        }()),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return Dismissible(
                            key: ValueKey(task.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Excluir Tarefa'),
                                  content: Text('Tem certeza que deseja excluir esta tarefa?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancelar')),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Excluir')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ApiService.deleteTask(task.id);
                                setState(_loadTasks);
                              }
                              return confirm ?? false;
                            },
                            child: GestureDetector(
                              onTap: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AddTaskScreen(taskToEdit: task)),
                                );
                                if (updated == true) {
                                  setState(_loadTasks);
                                }
                              },
                              child: Card(
                                elevation: 2,
                                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  title: Text(
                                    task.title,
                                    style: task.status == 'done'
                                        ? TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
                                        : TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text('Para: ${task.dueDate.toLocal().toIso8601String().split("T").first}'),
                                  trailing: IconButton(
                                    icon: Icon(
                                      task.status == 'done' ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: task.status == 'done' ? Colors.green : Colors.grey,
                                    ),
                                    onPressed: () => _toggleStatus(task),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ToggleButtons(
                  isSelected: TaskFilter.values.map((f) => f == _filter).toList(),
                  onPressed: (index) {
                    setState(() {
                      _filter = TaskFilter.values[index];
                    });
                  },
                  children: [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Todas')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Pendentes')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Concluídas')),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTaskScreen()),
          );
          if (added == true) {
            setState(_loadTasks);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}