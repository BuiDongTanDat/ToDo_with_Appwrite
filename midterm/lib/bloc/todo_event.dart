import 'package:equatable/equatable.dart';
import '../model/TodoModel.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final TodoModel todo;

  const AddTodo(this.todo);

  @override
  List<Object> get props => [todo];
}

class UpdateTodo extends TodoEvent {
  final TodoModel todo;

  const UpdateTodo(this.todo);

  @override
  List<Object> get props => [todo];
}

class DeleteTodo extends TodoEvent {
  final String id;

  const DeleteTodo(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleTodoCompletion extends TodoEvent {
  final String id;
  final bool isCompleted;

  const ToggleTodoCompletion(this.id, this.isCompleted);

  @override
  List<Object> get props => [id, isCompleted];
}

class ToggleTodoNotification extends TodoEvent {
  final String id;
  final bool isNotified;

  const ToggleTodoNotification(this.id, this.isNotified);

  @override
  List<Object> get props => [id, isNotified];
}

class ResetTodos extends TodoEvent {}
