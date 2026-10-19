class TaskModel {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String subjectName;
  final DateTime? dueDate;
  final bool completed;
  final String priority;
  final String userId;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.subjectName,
    this.dueDate,
    required this.completed,
    required this.priority,
    required this.userId,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data) {
    return TaskModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      dueDate: data['dueDate'] != null ? DateTime.tryParse(data['dueDate']) : null,
      completed: data['completed'] ?? false,
      priority: data['priority'] ?? 'media',
      userId: data['userId'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'dueDate': dueDate?.toIso8601String(),
        'completed': completed,
        'priority': priority,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
      };

  TaskModel copyWith({
    String? title,
    String? description,
    String? subjectId,
    String? subjectName,
    DateTime? dueDate,
    bool? completed,
    String? priority,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
