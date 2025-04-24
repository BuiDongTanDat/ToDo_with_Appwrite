import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midterm/bloc/todo_event.dart';
import 'package:midterm/bloc/todo_state.dart';
import '../model/ToDo.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  List<ToDo> _todos = [];

  TodoBloc() : super(TodoInitial()) {
    // Khởi tạo mẫu dữ liệu
    _todos = [
      ToDo(
        id: '1',
        title: 'Buy groceries',
        desc: 'Milk, Bread, Eggs',
        dueDate: DateTime.now(),
        color: 'green',
        isNotified: true,
      ),
      ToDo(
        id: '2',
        title: 'Finish report',
        desc: 'Complete the quarterly report',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        color: 'blue',
      ),
      ToDo(
        id: '3',
        title: 'Call mom',
        desc: 'Check in and catch up',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        color: 'red',
      ),
      ToDo(
        id: '4',
        title: 'Buy groceries',
        desc: 'Fruits, Vegetables',
        dueDate: DateTime.now(),
        color: 'green',
        isNotified: true,
      ),
      ToDo(
        id: '5',
        title: 'Finish report',
        desc: 'Finalize slides',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        color: 'blue',
      ),
      ToDo(
        id: '6',
        title: 'Call mom',
        desc: 'Plan weekend visit',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        color: 'red',
      ),
      ToDo(
        id: '7',
        title: 'Buy groceries',
        desc: 'Milk, Bread, Eggs',
        dueDate: DateTime.now(),
        color: 'green',
        isNotified: true,
      ),
      ToDo(
        id: '8',
        title: 'Finish report',
        desc: 'Review data',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        color: 'blue',
      ),
      ToDo(
        id: '9',
        title: 'Call mom',
        desc: 'Discuss family event',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        color: 'red',
      ),
    ];

    // Đăng ký các handler cho sự kiện
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ToggleTodoCompletion>(_onToggleTodoCompletion);
    on<ToggleTodoNotification>(_onToggleTodoNotification);
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      await Future.delayed(const Duration(seconds: 4)); // Giả lập tải dữ liệu
      emit(TodoLoaded(List.from(_todos)));
    } catch (e) {
      emit(TodoError('Failed to load todos: $e'));
    }
  }

  void _onAddTodo(AddTodo event, Emitter<TodoState> emit) {
    try {
      _todos.add(event.todo);
      emit(TodoLoaded(List.from(_todos)));
    } catch (e) {
      emit(TodoError('Failed to add todo: $e'));
    }
  }

  void _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) {
    try {
      final index = _todos.indexWhere((todo) => todo.id == event.todo.id);
      if (index != -1) {
        _todos[index] = event.todo;
        emit(TodoLoaded(List.from(_todos)));
      } else {
        emit(TodoError('Todo not found'));
      }
    } catch (e) {
      emit(TodoError('Failed to update todo: $e'));
    }
  }

  void _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) {
    try {
      _todos.removeWhere((todo) => todo.id == event.id);
      emit(TodoLoaded(List.from(_todos)));
    } catch (e) {
      emit(TodoError('Failed to delete todo: $e'));
    }
  }

  void _onToggleTodoCompletion(ToggleTodoCompletion event, Emitter<TodoState> emit) {
    try {
      final index = _todos.indexWhere((todo) => todo.id == event.id);
      if (index != -1) {
        _todos[index] = ToDo(
          id: _todos[index].id,
          title: _todos[index].title,
          desc: _todos[index].desc,
          dueDate: _todos[index].dueDate,
          isCompleted: event.isCompleted,
          color: _todos[index].color,
          isNotified: _todos[index].isNotified,
        );
        emit(TodoLoaded(List.from(_todos)));
      } else {
        emit(TodoError('Todo not found'));
      }
    } catch (e) {
      emit(TodoError('Failed to toggle completion: $e'));
    }
  }

  void _onToggleTodoNotification(ToggleTodoNotification event, Emitter<TodoState> emit) {
    try {
      final index = _todos.indexWhere((todo) => todo.id == event.id);
      if (index != -1) {
        _todos[index] = ToDo(
          id: _todos[index].id,
          title: _todos[index].title,
          desc: _todos[index].desc,
          dueDate: _todos[index].dueDate,
          isCompleted: _todos[index].isCompleted,
          color: _todos[index].color,
          isNotified: event.isNotified,
        );
        emit(TodoLoaded(List.from(_todos)));
      } else {
        emit(TodoError('Todo not found'));
      }
    } catch (e) {
      emit(TodoError('Failed to toggle notification: $e'));
    }
  }
}