import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _title = widget.taskToEdit!.title;
      _description = widget.taskToEdit!.description ?? '';
      _dueDate = widget.taskToEdit!.dueDate;
    } else {
      _title = '';
      _description = '';
    }
    if (widget.taskToEdit != null) {
      _dueDate = widget.taskToEdit!.dueDate;
    } else {
      _dueDate = DateTime.now();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (widget.taskToEdit != null) {
      await ApiService.updateTask(Task(
        id: widget.taskToEdit!.id,
        title: _title,
        description: _description,
        dueDate: _dueDate,
        status: widget.taskToEdit!.status,
      ));
    } else {
      await ApiService.addTask(_title, _description, _dueDate);
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskToEdit != null ? 'Editar Tarefa' : 'Adicionar Tarefa'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o título' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Descrição'),
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  // ignore: unnecessary_null_comparison
                  Text(_dueDate == null ? 'Sem data' : 'Data: ${_dueDate.toLocal()}'.split(' ')[0]),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dueDate = pickedDate;
                        });
                      }
                    },
                    child: Text('Selecionar Data'),
                  ),
                ],
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.taskToEdit != null ? 'Atualizar' : 'Adicionar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}