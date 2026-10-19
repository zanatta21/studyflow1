class SubjectModel {
  final String id;
  final String name;
  final String professor;
  final String description;
  final String color;
  final String userId;
  final DateTime createdAt;

  SubjectModel({
    required this.id,
    required this.name,
    required this.professor,
    required this.description,
    required this.color,
    required this.userId,
    required this.createdAt,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> data) {
    return SubjectModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      professor: data['professor'] ?? '',
      description: data['description'] ?? '',
      color: data['color'] ?? '#0F766E',
      userId: data['userId'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'professor': professor,
        'description': description,
        'color': color,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
      };

  SubjectModel copyWith({
    String? name,
    String? professor,
    String? description,
    String? color,
  }) {
    return SubjectModel(
      id: id,
      name: name ?? this.name,
      professor: professor ?? this.professor,
      description: description ?? this.description,
      color: color ?? this.color,
      userId: userId,
      createdAt: createdAt,
    );
  }
}
