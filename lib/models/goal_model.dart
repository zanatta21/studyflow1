class GoalModel {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final String unit;
  final DateTime? deadline;
  final bool completed;
  final String userId;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    this.deadline,
    required this.completed,
    required this.userId,
    required this.createdAt,
  });

  double get progress {
    if (targetValue <= 0) return 0;
    final p = currentValue / targetValue;
    return p > 1 ? 1.0 : p;
  }

  factory GoalModel.fromMap(Map<String, dynamic> data) {
    return GoalModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      targetValue: data['targetValue'] ?? 0,
      currentValue: data['currentValue'] ?? 0,
      unit: data['unit'] ?? 'horas',
      deadline: data['deadline'] != null ? DateTime.tryParse(data['deadline']) : null,
      completed: data['completed'] ?? false,
      userId: data['userId'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'unit': unit,
        'deadline': deadline?.toIso8601String(),
        'completed': completed,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
      };

  GoalModel copyWith({
    String? title,
    String? description,
    int? targetValue,
    int? currentValue,
    String? unit,
    DateTime? deadline,
    bool? completed,
  }) {
    return GoalModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      deadline: deadline ?? this.deadline,
      completed: completed ?? this.completed,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
