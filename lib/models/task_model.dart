class Task {
  final String id;
  final String description;
  final bool completed;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.description,
    this.completed = false,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a Task from JSON (Node.js/MongoDB response)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] as String,
      description: json['description'] as String,
      completed: json['completed'] as bool? ?? false,
      owner: json['owner'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Method to convert Task instance back to JSON (for API updates)
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'completed': completed,
    };
  }
}