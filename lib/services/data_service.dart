import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/subject_model.dart';
import '../models/task_model.dart';
import '../models/exam_model.dart';
import '../models/goal_model.dart';
import 'local_storage.dart';
import 'auth_service.dart';

class DataService extends ChangeNotifier {
  final AuthService auth;
  final _uuid = const Uuid();

  List<SubjectModel> subjects = [];
  List<TaskModel> tasks = [];
  List<ExamModel> exams = [];
  List<GoalModel> goals = [];
  bool isLoading = false;
  String? errorMessage;

  DataService(this.auth);

  String get _uid => auth.userId;

  String get _subjectsKey => 'subjects_$_uid';
  String get _tasksKey => 'tasks_$_uid';
  String get _examsKey => 'exams_$_uid';
  String get _goalsKey => 'goals_$_uid';

  Future<void> loadAll() async {
    if (_uid.isEmpty) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      subjects = LocalStorage.getList(_subjectsKey).map((m) => SubjectModel.fromMap(m)).toList();
      tasks = LocalStorage.getList(_tasksKey).map((m) => TaskModel.fromMap(m)).toList();
      exams = LocalStorage.getList(_examsKey).map((m) => ExamModel.fromMap(m)).toList();
      goals = LocalStorage.getList(_goalsKey).map((m) => GoalModel.fromMap(m)).toList();
      subjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      exams.sort((a, b) => a.date.compareTo(b.date));
      goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      errorMessage = 'Erro ao carregar dados.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSubjects() async {
    await LocalStorage.setList(_subjectsKey, subjects.map((s) => s.toMap()).toList());
  }

  Future<void> _saveTasks() async {
    await LocalStorage.setList(_tasksKey, tasks.map((t) => t.toMap()).toList());
  }

  Future<void> _saveExams() async {
    await LocalStorage.setList(_examsKey, exams.map((e) => e.toMap()).toList());
  }

  Future<void> _saveGoals() async {
    await LocalStorage.setList(_goalsKey, goals.map((g) => g.toMap()).toList());
  }

  Future<bool> createSubject(SubjectModel s) async {
    try {
      final novo = SubjectModel(
        id: _uuid.v4(),
        name: s.name,
        professor: s.professor,
        description: s.description,
        color: s.color,
        userId: _uid,
        createdAt: DateTime.now(),
      );
      subjects.insert(0, novo);
      await _saveSubjects();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao criar disciplina.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubject(SubjectModel s) async {
    try {
      final i = subjects.indexWhere((x) => x.id == s.id);
      if (i < 0) return false;
      subjects[i] = s;
      await _saveSubjects();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao atualizar disciplina.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(String id) async {
    try {
      subjects.removeWhere((s) => s.id == id);
      await _saveSubjects();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao excluir disciplina.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createTask(TaskModel t) async {
    try {
      final novo = TaskModel(
        id: _uuid.v4(),
        title: t.title,
        description: t.description,
        subjectId: t.subjectId,
        subjectName: t.subjectName,
        dueDate: t.dueDate,
        completed: false,
        priority: t.priority,
        userId: _uid,
        createdAt: DateTime.now(),
      );
      tasks.insert(0, novo);
      await _saveTasks();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao criar tarefa.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel t) async {
    try {
      final i = tasks.indexWhere((x) => x.id == t.id);
      if (i < 0) return false;
      tasks[i] = t;
      await _saveTasks();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao atualizar tarefa.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      tasks.removeWhere((t) => t.id == id);
      await _saveTasks();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao excluir tarefa.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTask(TaskModel t) async {
    return updateTask(t.copyWith(completed: !t.completed));
  }

  Future<bool> createExam(ExamModel e) async {
    try {
      final novo = ExamModel(
        id: _uuid.v4(),
        title: e.title,
        subjectId: e.subjectId,
        subjectName: e.subjectName,
        date: e.date,
        location: e.location,
        notes: e.notes,
        grade: e.grade,
        completed: false,
        userId: _uid,
        createdAt: DateTime.now(),
      );
      exams.add(novo);
      exams.sort((a, b) => a.date.compareTo(b.date));
      await _saveExams();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao criar prova.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExam(ExamModel e) async {
    try {
      final i = exams.indexWhere((x) => x.id == e.id);
      if (i < 0) return false;
      exams[i] = e;
      exams.sort((a, b) => a.date.compareTo(b.date));
      await _saveExams();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao atualizar prova.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExam(String id) async {
    try {
      exams.removeWhere((e) => e.id == id);
      await _saveExams();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao excluir prova.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createGoal(GoalModel g) async {
    try {
      final novo = GoalModel(
        id: _uuid.v4(),
        title: g.title,
        description: g.description,
        targetValue: g.targetValue,
        currentValue: 0,
        unit: g.unit,
        deadline: g.deadline,
        completed: false,
        userId: _uid,
        createdAt: DateTime.now(),
      );
      goals.insert(0, novo);
      await _saveGoals();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao criar meta.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGoal(GoalModel g) async {
    try {
      final completed = g.currentValue >= g.targetValue;
      final updated = g.copyWith(completed: completed);
      final i = goals.indexWhere((x) => x.id == g.id);
      if (i < 0) return false;
      goals[i] = updated;
      await _saveGoals();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao atualizar meta.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGoal(String id) async {
    try {
      goals.removeWhere((g) => g.id == id);
      await _saveGoals();
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Erro ao excluir meta.';
      notifyListeners();
      return false;
    }
  }

  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((t) => t.completed).length;
  double get taskProgress => totalTasks == 0 ? 0 : completedTasks / totalTasks;
  int get totalExams => exams.length;
  int get completedExams => exams.where((e) => e.completed).length;
  double get examProgress => totalExams == 0 ? 0 : completedExams / totalExams;
  int get totalGoals => goals.length;
  int get completedGoals => goals.where((g) => g.completed).length;
  double get goalProgress => totalGoals == 0 ? 0 : completedGoals / totalGoals;

  List<ExamModel> get upcomingExams {
    final now = DateTime.now();
    return exams.where((e) => !e.completed && e.date.isAfter(now.subtract(const Duration(days: 1)))).toList();
  }

  List<TaskModel> get pendingTasks => tasks.where((t) => !t.completed).toList();

  List<TaskModel> tasksForDate(DateTime date) {
    return tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == date.year && t.dueDate!.month == date.month && t.dueDate!.day == date.day;
    }).toList();
  }

  List<ExamModel> examsForDate(DateTime date) {
    return exams.where((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day).toList();
  }
}
