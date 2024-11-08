import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const ToDoApp());

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ToDoListScreen(),
    );
  }
}

class ToDo {
  String title;
  bool isCompleted;

  ToDo({
    required this.title,
    this.isCompleted = false,
  });

  // Convert to and from JSON for storing in SharedPreferences
  Map<String, dynamic> toJson() => {
        'title': title,
        'isCompleted': isCompleted,
      };

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      title: json['title'],
      isCompleted: json['isCompleted'],
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  List<ToDo> _todoList = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    _prefs = await SharedPreferences.getInstance();
    List<String>? tasks = _prefs.getStringList('tasks');
    if (tasks != null) {
      setState(() {
        _todoList =
            tasks.map((task) => ToDo.fromJson(json.decode(task))).toList();
      });
    }
  }

  void _saveTasks() {
    List<String> tasks =
        _todoList.map((task) => json.encode(task.toJson())).toList();
    _prefs.setStringList('tasks', tasks);
  }

  void _addTask(String title) {
    setState(() {
      _todoList.add(ToDo(
        title: title,
      ));
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _todoList[index].isCompleted = !_todoList[index].isCompleted;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController taskController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: const InputDecoration(labelText: 'New Task'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (taskController.text.isNotEmpty) {
                      _addTask(taskController.text);
                      taskController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _todoList[index].title,
                    style: TextStyle(
                      decoration: _todoList[index].isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                    value: _todoList[index].isCompleted,
                    onChanged: (_) => _toggleTaskCompletion(index),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
