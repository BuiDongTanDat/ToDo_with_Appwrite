import 'package:equatable/equatable.dart';
import 'package:midterm/model/TodoModel.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {
  @override
  List<Object?> get props => [];
}

class TodoLoading extends TodoState {
  @override
  List<Object?> get props => [];
}

class TodoLoaded extends TodoState {
  final List<TodoModel> todos;
  final String userName;
  final bool isFromCache;

  const TodoLoaded(this.todos, this.userName, {this.isFromCache = false});

  @override
  List<Object?> get props => [todos, userName, isFromCache];
}

class TodoError extends TodoState {
  final String message;
  final List<TodoModel>? cachedTodos;

  const TodoError(this.message, {this.cachedTodos});

  @override
  List<Object?> get props => [message, cachedTodos];
}

class TodoSessionExpired extends TodoState {
  @override
  List<Object?> get props => [];
}