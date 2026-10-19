class ExamModel {
  final String id;
  final String title;
  final String subjectId;
  final String subjectName;
  final DateTime date;
  final String location;
  final String notes;
  final double? grade;
  final bool completed;
  final String userId;
  final DateTime createdAt;

  ExamModel({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subjectName,
    required this.date,
    required this.location,
    required this.notes,
    this.grade,
    required this.completed,
    required this.userId,
    required this.createdAt,
  });

  factory ExamModel.fromMap(Map<String, dynamic> data) {
    return ExamModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      location: data['location'] ?? '',
      notes: data['notes'] ?? '',
      grade: (data['grade'] as num?)?.toDouble(),
      completed: data['completed'] ?? false,
      userId: data['userId'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'date': date.toIso8601String(),
        'location': location,
        'notes': notes,
        'grade': grade,
        'completed': completed,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
      };

  ExamModel copyWith({
    String? title,
    String? subjectId,
    String? subjectName,
    DateTime? date,
    String? location,
    String? notes,
    double? grade,
    bool? completed,
  }) {
    return ExamModel(
      id: id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      date: date ?? this.date,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      grade: grade ?? this.grade,
      completed: completed ?? this.completed,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
