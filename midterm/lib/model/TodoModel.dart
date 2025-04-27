class TodoModel {
  String id;
  String title;
  String description;
  DateTime dueDate; // Single field for both date and time
  String color;
  bool isCompleted;
  bool isNotified;

  TodoModel({
    this.id = '',
    required this.title,
    required this.description,
    required this.dueDate,
    required this.color,
    this.isCompleted = false,
    this.isNotified = false,
  });

  // Convert ToDo to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': description,
      'dueDate': dueDate.toIso8601String(),
      'color': color,
      'isCompleted': isCompleted,
      'isNotified': isNotified,
    };
  }

  // Create ToDo from Map
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'],
      title: map['title'],
      description: map['desc'],
      dueDate: DateTime.parse(map['dueDate']),
      color: map['color'],
      isCompleted: map['isCompleted'],
      isNotified: map['isNotified'],
    );
  }
}