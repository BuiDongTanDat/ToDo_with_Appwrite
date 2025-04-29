import 'package:equatable/equatable.dart';

class TodoModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String color;
  final bool isCompleted;
  final bool isNotified;
  final DateTime? notificationDate;
  final String userId;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.color,
    required this.isCompleted,
    required this.isNotified,
    this.notificationDate,
    required this.userId,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        color,
        isCompleted,
        isNotified,
        notificationDate,
        userId,
      ];
}