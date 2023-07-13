import 'dart:convert';

import 'package:flutter/material.dart';

import '../main.dart';

// Task 데이터의 형식을 정해줍니다. 추후 isPinned, updatedAt 등의 정보도 저장할 수 있습니다.
class Task {
  Task(
      {required this.content,
      required this.dueDate,
      this.detail,
      this.category = 7,
      this.isPinned = false,
      this.updatedAt,
      this.isChecked = false});

  String content;
  DateTime dueDate;
  String? detail;
  int category;
  bool isPinned;
  DateTime? updatedAt;
  bool isChecked;

  Map toJson() {
    return {
      'content': content,
      'dueDate': dueDate.toIso8601String(),
      'detail': detail,
      'category': category,
      'isPinned': isPinned,
      'updatedAt': updatedAt?.toIso8601String(),
      'isChecked': isChecked,
    };
  }

  factory Task.fromJson(json) {
    return Task(
      content: json['content'],
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime(2020, 1, 1)),
      detail: json['detail'] ?? '',
      category: json['category'] ?? 7,
      isPinned: json['isPinned'] ?? false,
      updatedAt:
          json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt']),
      isChecked: json['isChecked'] ?? false,
    );
  }
}

// Task 데이터는 모두 여기서 관리
class TaskService extends ChangeNotifier {
  TaskService() {
    loadTaskList();
  }

  List<Task> taskList = [
    Task(
        content: '장보기 목록: 사과, 양파',
        dueDate: DateTime(2020, 1, 1)), // 더미(dummy) 데이터
    Task(content: '메모 메모', dueDate: DateTime(2020, 1, 1)), // 더미(dummy) 데이터
  ];

  createTask(
      {required String content,
      required DateTime dueDate,
      String? detail,
      required int category}) {
    Task task = Task(
        content: content,
        updatedAt: DateTime.now(),
        dueDate: dueDate,
        detail: detail,
        category: category);
    taskList.add(task);
    taskList.sort(((a, b) => a.dueDate.compareTo(b.dueDate)));

    notifyListeners();
    saveTaskList(); // Consumer<TaskService>의 builder 부분을 호출해서 화면 새로고침
  }

  updateTask(
      {required int index,
      required String content,
      required DateTime dueDate}) {
    Task task = taskList[index];
    task.content = content;
    task.dueDate = dueDate;
    task.updatedAt = DateTime.now();
    notifyListeners();
    saveTaskList();
  }

  updateDetail({required int index, required String detail}) {
    Task task = taskList[index];
    task.detail = detail;
    notifyListeners();
    saveTaskList();
  }

  updateCategory({required int index, required int category}) {
    Task task = taskList[index];
    task.category = category;
    notifyListeners();
    saveTaskList();
  }

  updateCheckTask({required int index}) {
    Task task = taskList[index];
    task.isChecked = !task.isChecked;
    notifyListeners();
    saveTaskList();
  }

  updatePinTask({required int index}) {
    Task task = taskList[index];
    task.isPinned = !task.isPinned;
    taskList = [
      ...taskList.where((element) => element.isPinned),
      ...taskList.where((element) => !element.isPinned),
    ];
    notifyListeners();
    saveTaskList();
  }

  deleteTask({required int index}) {
    taskList.removeAt(index);
    notifyListeners();
    saveTaskList();
  }

  saveTaskList() {
    List taskJsonList = taskList.map((task) => task.toJson()).toList();
    // [{"content": "1"}, {"content": "2"}]

    String jsonString = jsonEncode(taskJsonList);
    // '[{"content": "1"}, {"content": "2"}]'

    prefs.setString('taskList', jsonString);
  }

  loadTaskList() {
    String? jsonString = prefs.getString('taskList');
    // '[{"content": "1"}, {"content": "2"}]'

    if (jsonString == null) return; // null 이면 로드하지 않음

    List taskJsonList = jsonDecode(jsonString);
    // [{"content": "1"}, {"content": "2"}]

    taskList = taskJsonList.map((json) => Task.fromJson(json)).toList();
  }
}