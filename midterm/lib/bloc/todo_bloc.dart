import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midterm/bloc/todo_event.dart';
import 'package:midterm/bloc/todo_state.dart';
import 'package:midterm/model/TodoModel.dart';
import '../service/notification_service.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  List<TodoModel> _todos = [];
  final NotificationService _notificationService = NotificationService();

  TodoBloc() : super(TodoInitial()) {
    // Initialize NotificationService
    _initializeNotificationService();

    // Sample data with dueDates in the near future for testing
    _todos = [
      TodoModel(
        id: '1',
        title: 'Buy groceries show notification',
        description: 'Milk, Bread, Eggs',
        dueDate: DateTime.now().add(const Duration(minutes: 10)),
        notificationDate: DateTime.now().add(const Duration(minutes: 7)),
        color: 'green',
        isNotified: true,
      ),
      TodoModel(
        id: '2',
        title: 'Finish report',
        description: 'Complete the quarterly report',
        dueDate: DateTime.now().add(const Duration(minutes: 20)),
        notificationDate: DateTime.now().add(const Duration(minutes: 17)),
        color: 'blue',
        isNotified: true,
      ),
      TodoModel(
        id: '3',
        title: 'Call mom',
        description: 'Check in and catch up',
        dueDate: DateTime.now().add(const Duration(minutes: 30)),
        notificationDate: DateTime.now().add(const Duration(minutes: 27)),
        color: 'red',
        isNotified: true,
      ),
      TodoModel(
        id: '4',
        title: 'Buy groceries',
        description: 'Fruits, Vegetables',
        dueDate: DateTime.now().add(const Duration(minutes: 40)),
        notificationDate: DateTime.now().add(const Duration(minutes: 37)),
        color: 'green',
        isNotified: true,
      ),
      TodoModel(
        id: '5',
        title: 'Finish report',
        description: 'Finalize slides',
        dueDate: DateTime.now().add(const Duration(minutes: 50)),
        notificationDate: DateTime.now().add(const Duration(minutes: 47)),
        color: 'blue',
        isNotified: true,
      ),
      TodoModel(
        id: '6',
        title: 'Call mom',
        description: 'Plan weekend visit',
        dueDate: DateTime.now().add(const Duration(minutes: 60)),
        notificationDate: DateTime.now().add(const Duration(minutes: 57)),
        color: 'red',
        isNotified: true,
      ),
      TodoModel(
        id: '7',
        title: 'Buy groceries',
        description: 'Milk, Bread, Eggs',
        dueDate: DateTime.now().add(const Duration(minutes: 70)),
        notificationDate: DateTime.now().add(const Duration(minutes: 67)),
        color: 'green',
        isNotified: true,
      ),
      TodoModel(
        id: '8',
        title: 'Finish report',
        description: 'Review data',
        dueDate: DateTime.now().add(const Duration(minutes: 80)),
        notificationDate: DateTime.now().add(const Duration(minutes: 77)),
        color: 'blue',
        isNotified: true,
      ),
      TodoModel(
        id: '9',
        title: 'Call mom',
        description: 'Discuss family event',
        dueDate: DateTime.now().add(const Duration(minutes: 90)),
        notificationDate: DateTime.now().add(const Duration(minutes: 87)),
        color: 'red',
        isNotified: true,
      ),
    ];

    // Register event handlers
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ToggleTodoCompletion>(_onToggleTodoCompletion);
    on<ToggleTodoNotification>(_onToggleTodoNotification);
  }

  Future<void> _initializeNotificationService() async {
    await _notificationService.init();
  }

  Future<void> _scheduleNotificationIfNeeded(TodoModel todo) async {
    try {
      if (!todo.isCompleted && todo.isNotified && todo.notificationDate != null) {
        // Use the notificationDate for scheduling
        final notificationTime = todo.notificationDate!;
        print("Scheduling notification for todo ${todo.id}: $notificationTime");

        // Only schedule if notification time is in the future
        if (notificationTime.isAfter(DateTime.now())) {
          await _notificationService.scheduleNotification(
            id: todo.id.hashCode,
            title: 'ToDo nhắc em: ${todo.title}',
            body: todo.description ?? 'Reminder: Hết hạn rồi nè!',
            scheduledDate: notificationTime,
          );
        } else {
          print('Notification time is in the past for todo ${todo.id}: $notificationTime');
        }
      } else {
        // Cancel notification if not needed
        await _notificationService.cancelNotification(todo.id.hashCode);
      }
    } catch (e) {
      print('Error scheduling notification for todo ${todo.id}: $e');
    }
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      // Wait for notification service initialization
      await _initializeNotificationService();

      // Schedule notifications for all valid todos
      for (var todo in _todos) {
        await _scheduleNotificationIfNeeded(todo);
      }
      emit(TodoLoaded(List.from(_todos)));
    } catch (e) {
      emit(TodoError('Failed to load todos: $e'));
    }
  }

  void _onAddTodo(AddTodo event, Emitter<TodoState> emit) {
    try {
      _todos.add(event.todo);
      _scheduleNotificationIfNeeded(event.todo);
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
        _scheduleNotificationIfNeeded(event.todo);
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
      final todo = _todos.firstWhere((t) => t.id == event.id, orElse: () => throw Exception('Todo not found'));
      _todos.removeWhere((t) => t.id == event.id);
      _notificationService.cancelNotification(event.id.hashCode);
      emit(TodoLoaded(List.from(_todos)));
    } catch (e) {
      emit(TodoError('Failed to delete todo: $e'));
    }
  }

  void _onToggleTodoCompletion(ToggleTodoCompletion event, Emitter<TodoState> emit) {
    try {
      final index = _todos.indexWhere((todo) => todo.id == event.id);
      if (index != -1) {
        _todos[index] = TodoModel(
          id: _todos[index].id,
          title: _todos[index].title,
          description: _todos[index].description,
          dueDate: _todos[index].dueDate,
          isCompleted: event.isCompleted,
          color: _todos[index].color,
          isNotified: _todos[index].isNotified,
          notificationDate: _todos[index].notificationDate,
        );
        _scheduleNotificationIfNeeded(_todos[index]);
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
        _todos[index] = TodoModel(
          id: _todos[index].id,
          title: _todos[index].title,
          description: _todos[index].description,
          dueDate: _todos[index].dueDate,
          isCompleted: _todos[index].isCompleted,
          color: _todos[index].color,
          isNotified: event.isNotified,
          notificationDate: event.isNotified
              ? (_todos[index].notificationDate ?? _todos[index].dueDate.subtract(Duration(hours: 24)))
              : null,
        );
        _scheduleNotificationIfNeeded(_todos[index]);
        emit(TodoLoaded(List.from(_todos)));
      } else {
        emit(TodoError('Todo not found'));
      }
    } catch (e) {
      emit(TodoError('Failed to toggle notification: $e'));
    }
  }
}