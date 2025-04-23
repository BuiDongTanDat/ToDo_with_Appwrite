class ToDo {
  String id;
  String title;
  DateTime dueDate;
  bool isCompleted;
  String color; // e.g., 'red', 'blue', 'green'
  bool isNotified;

  ToDo({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    required this.color,
    this.isNotified = false,
  });

  // Convert ToDo to Map for storage (if needed)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'color': color,
      'isNotified': isNotified,
    };
  }

  // Create ToDo from Map
  factory ToDo.fromMap(Map<String, dynamic> map) {
    return ToDo(
      id: map['id'],
      title: map['title'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'],
      color: map['color'],
      isNotified: map['isNotified'],
    );
  }
}