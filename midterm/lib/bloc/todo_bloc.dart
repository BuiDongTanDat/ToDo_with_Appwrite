import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:midterm/bloc/todo_event.dart';
import 'package:midterm/bloc/todo_state.dart';
import 'package:midterm/model/TodoModel.dart';
import 'package:midterm/service/check_network.dart';
import '../backend/appwrite_config.dart';
import '../service/notification_service.dart';
import '../backend/controllers/TodoController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:retry/retry.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  List<TodoModel> _todos = [];
  String _currentUserName = 'User'; // Store username for consistency
  final NotificationService _notificationService = NotificationService();

  TodoBloc() : super(TodoInitial()) {
    _initializeNotificationService();

    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ToggleTodoCompletion>(_onToggleTodoCompletion);
    on<ToggleTodoNotification>(_onToggleTodoNotification);
    on<ResetTodos>(_onResetTodos);
  }

  Future<void> _initializeNotificationService() async {
    await _notificationService.init();
  }

  Future<void> _saveTodosToCache(List<TodoModel> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = todos
          .map((todo) => {
                'id': todo.id,
                'title': todo.title,
                'description': todo.description,
                'dueDate': todo.dueDate.toIso8601String(),
                'color': todo.color,
                'isCompleted': todo.isCompleted,
                'isNotified': todo.isNotified,
                'notificationDate': todo.notificationDate?.toIso8601String(),
                'userId': todo.userId,
              })
          .toList();
      await prefs.setString('cached_todos', jsonEncode(todosJson));
      print('Saved ${todos.length} todos to cache');
    } catch (e) {
      print('Error saving todos to cache: $e');
    }
  }

  Future<List<TodoModel>> _loadTodosFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedTodos = prefs.getString('cached_todos');
      if (cachedTodos != null) {
        final todosJson = jsonDecode(cachedTodos) as List<dynamic>;
        return todosJson.map((data) {
          return TodoModel(
            id: data['id'] as String,
            title: data['title'] as String? ?? 'Untitled',
            description: data['description'] as String?,
            dueDate: DateTime.parse(data['dueDate'] as String),
            color: data['color'] as String? ?? 'green',
            isCompleted: data['isCompleted'] as bool? ?? false,
            isNotified: data['isNotified'] as bool? ?? false,
            notificationDate: data['notificationDate'] != null
                ? DateTime.parse(data['notificationDate'] as String)
                : null,
            userId: data['userId'] as String? ?? '',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error loading todos from cache: $e');
      return [];
    }
  }

  Future<void> _scheduleNotificationIfNeeded(TodoModel todo) async {
    try {
      if (!todo.isCompleted &&
          todo.isNotified &&
          todo.notificationDate != null) {
        final notificationTime = todo.notificationDate!;
        print("Scheduling notification for todo ${todo.id}: $notificationTime");

        if (notificationTime.isAfter(DateTime.now())) {
          await _notificationService.scheduleNotification(
            id: todo.id.hashCode,
            title: 'ToDo nhắc em: ${todo.title}',
            body: todo.description ?? 'Reminder: Hết hạn rồi em ơi!',
            scheduledDate: notificationTime,
          );
        } else {
          print(
              'Notification time is in the past for todo ${todo.id}: $notificationTime');
        }
      } else {
        await _notificationService.cancelNotification(todo.id.hashCode);
      }
    } catch (e) {
      print('Error scheduling notification for todo ${todo.id}: $e');
    }
  }

  Future<bool> _checkNetworkConnectivity() async {
    return await checkNetworkConnectivity();
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      await _initializeNotificationService();

      // Load todos and username from cache
      final cachedTodos = await _loadTodosFromCache();
      final prefs = await SharedPreferences.getInstance();
      final cachedUsername = prefs.getString('user_name') ?? 'User';
      _todos = cachedTodos;
      _currentUserName = cachedUsername;

      // Emit cached todos with username
      emit(TodoLoaded(List.from(_todos), cachedUsername, isFromCache: true));

      // Check network connectivity
      bool isConnected = await _checkNetworkConnectivity();
      if (isConnected) {
        final account = Account(client);
        try {
          final user = await account.get();
          final userId = user.$id;
          final serverUsername =
              user.name.isNotEmpty ? user.name : cachedUsername;
          _currentUserName = serverUsername;

          final result = await retry(
            () => getTodos(userId).timeout(const Duration(seconds: 10)),
            maxAttempts: 3,
            delayFactor: const Duration(seconds: 2),
            randomizationFactor: 0.5,
            onRetry: (error) {
              print('Retrying load todos due to error: $error');
            },
          );

          if (result['code'] == 200) {
            final documents = result['response'] as List<dynamic>;
            _todos = documents.map((doc) {
              final data = doc.data as Map<String, dynamic>;
              print('Processing document ${doc.$id}: $data');
              return TodoModel(
                id: doc.$id,
                title: data['title'] as String? ?? 'Untitled',
                description: data['description'] as String?,
                dueDate: DateTime.parse(data['dueDate'] as String? ??
                    DateTime.now().toIso8601String()),
                color: data['color'] as String? ?? 'green',
                isCompleted: data['isCompleted'] as bool? ?? false,
                isNotified: data['isNotified'] as bool? ?? false,
                notificationDate: (data['isNotified'] as bool? ?? false)
                    ? (data['notificationDate'] != null
                        ? DateTime.parse(data['notificationDate'] as String)
                        : DateTime.parse(data['dueDate'] as String? ??
                                DateTime.now().toIso8601String())
                            .subtract(const Duration(hours: 24)))
                    : null,
                userId: data['userId'] as String? ?? '',
              );
            }).toList();

            for (var todo in _todos) {
              await _scheduleNotificationIfNeeded(todo);
            }
            await _saveTodosToCache(_todos);
            await prefs.setString('user_name', serverUsername); // Update cache
            print(
                'Emitting TodoLoaded with ${_todos.length} todos from server');
            emit(TodoLoaded(List.from(_todos), serverUsername,
                isFromCache: false));
          } else {
            print('Failed to load todos from server: ${result['response']}');
            emit(TodoLoaded(List.from(_todos), _currentUserName,
                isFromCache: true));
          }
        } on AppwriteException catch (e) {
          if (e.code == 401) {
            // Unauthorized, session expired
            print('Session expired: $e');
            emit(TodoSessionExpired());
          } else {
            print('Appwrite error loading todos: $e');
            emit(TodoLoaded(List.from(_todos), _currentUserName,
                isFromCache: true));
          }
        }
      } else {
        print('No network connection, using cached todos');
        // Already emitted cached todos above
      }
    } catch (e) {
      print('Error loading todos: $e');
      emit(TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      bool isConnected = await _checkNetworkConnectivity();
      if (!isConnected) {
        print('No network connection, cannot add todo');
        emit(
            TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
        return;
      }

      if (_todos.any((todo) => todo.id == event.todo.id)) {
        print('Todo with ID ${event.todo.id} already exists');
        emit(
            TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
        return;
      }

      final result = await createOrUpdate(event.todo, 0);
      if (result['code'] == 201) {
        final responseDoc = result['response'] as dynamic;

        final newTodo = TodoModel(
          id: responseDoc.$id,
          title: event.todo.title,
          description: event.todo.description,
          dueDate: event.todo.dueDate,
          color: event.todo.color,
          isCompleted: event.todo.isCompleted,
          isNotified: event.todo.isNotified,
          notificationDate: event.todo.notificationDate,
          userId: event.todo.userId,
        );

        _todos.add(newTodo);
        await _scheduleNotificationIfNeeded(newTodo);
        await _saveTodosToCache(_todos);
        print('Emitting TodoLoaded with ${_todos.length} todos after add');
        emit(TodoLoaded(List.from(_todos), _currentUserName,
            isFromCache: false));
      } else {
        print('Failed to add todo: ${result['response']}');
        emit(
            TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
      }
    } catch (e) {
      print('Error adding todo: $e');
      emit(TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      bool isConnected = await _checkNetworkConnectivity();
      if (!isConnected) {
        print('No network connection, cannot update todo');
        emit(
            TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
        return;
      }

      final result = await createOrUpdate(event.todo, 1);
      if (result['code'] == 200) {
        final index = _todos.indexWhere((todo) => todo.id == event.todo.id);
        if (index != -1) {
          _todos[index] = event.todo;
          await _scheduleNotificationIfNeeded(event.todo);
          await _saveTodosToCache(_todos);
          print('Emitting TodoLoaded with ${_todos.length} todos after update');
          emit(TodoLoaded(List.from(_todos), _currentUserName,
              isFromCache: false));
        } else {
          print('Todo not found for update: ${event.todo.id}');
          emit(TodoLoaded(List.from(_todos), _currentUserName,
              isFromCache: true));
        }
      } else {
        print('Failed to update todo: ${result['response']}');
        emit(
            TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
      }
    } catch (e) {
      print('Error updating todo: $e');
      emit(TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      bool isConnected = await _checkNetworkConnectivity();
      if (!isConnected) {
        print('No network connection, cannot delete todo');
        emit(
            TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
        return;
      }

      print('Attempting to delete todo with ID: ${event.id}');
      final result = await delete(event.id);
      print('Delete result: $result');
      if (result['code'] == 200) {
        print('Before deletion, todos count: ${_todos.length}');
        _todos.removeWhere((t) => t.id == event.id);
        print('After deletion, todos count: ${_todos.length}');
        await _notificationService.cancelNotification(event.id.hashCode);
        await _saveTodosToCache(_todos);
        print('Emitting TodoLoaded with ${_todos.length} todos after delete');
        emit(TodoLoaded(List.from(_todos), _currentUserName,
            isFromCache: false));
      } else {
        print('Failed to delete todo: ${result['response']}');
        emit(
            TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
      }
    } catch (e) {
      print('Error deleting todo: $e');
      emit(TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
    }
  }

  Future<void> _onToggleTodoCompletion(
      ToggleTodoCompletion event, Emitter<TodoState> emit) async {
    try {
      bool isConnected = await _checkNetworkConnectivity();
      if (!isConnected) {
        print('No network connection, cannot toggle completion');
        emit(
            TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
        return;
      }

      final index = _todos.indexWhere((todo) => todo.id == event.id);
      if (index != -1) {
        final updatedTodo = TodoModel(
          id: _todos[index].id,
          title: _todos[index].title,
          description: _todos[index].description,
          dueDate: _todos[index].dueDate,
          isCompleted: event.isCompleted,
          color: _todos[index].color,
          isNotified: _todos[index].isNotified,
          notificationDate: _todos[index].notificationDate,
          userId: _todos[index].userId,
        );
        final result = await createOrUpdate(updatedTodo, 1);
        if (result['code'] == 200) {
          _todos[index] = updatedTodo;
          await _scheduleNotificationIfNeeded(updatedTodo);
          await _saveTodosToCache(_todos);
          print(
              'Emitting TodoLoaded with ${_todos.length} todos after toggle completion');
          emit(TodoLoaded(List.from(_todos), _currentUserName,
              isFromCache: false));
        } else {
          print('Failed to toggle completion: ${result['response']}');
          emit(TodoLoaded(List.from(_todos), _currentUserName,
              isFromCache: true));
        }
      } else {
        print('Todo not found for toggle completion: ${event.id}');
        emit(
            TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
      }
    } catch (e) {
      print('Error toggling completion: $e');
      emit(TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
    }
  }

  Future<void> _onToggleTodoNotification(
      ToggleTodoNotification event, Emitter<TodoState> emit) async {
    try {
      bool isConnected = await _checkNetworkConnectivity();
      if (!isConnected) {
        print('No network connection, cannot toggle notification');
        emit(
            TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
        return;
      }

      final index = _todos.indexWhere((todo) => todo.id == event.id);
      if (index != -1) {
        final updatedTodo = TodoModel(
          id: _todos[index].id,
          title: _todos[index].title,
          description: _todos[index].description,
          dueDate: _todos[index].dueDate,
          isCompleted: _todos[index].isCompleted,
          color: _todos[index].color,
          isNotified: event.isNotified,
          notificationDate: event.isNotified
              ? (_todos[index].notificationDate ??
                  _todos[index].dueDate.subtract(const Duration(hours: 24)))
              : null,
          userId: _todos[index].userId,
        );
        final result = await createOrUpdate(updatedTodo, 1);
        if (result['code'] == 200) {
          _todos[index] = updatedTodo;
          await _scheduleNotificationIfNeeded(updatedTodo);
          await _saveTodosToCache(_todos);
          print(
              'Emitting TodoLoaded with ${_todos.length} todos after toggle notification');
          emit(TodoLoaded(List.from(_todos), _currentUserName,
              isFromCache: false));
        } else {
          print('Failed to toggle notification: ${result['response']}');
          emit(TodoLoaded(List.from(_todos), _currentUserName,
              isFromCache: true));
        }
      } else {
        print('Todo not found for toggle notification: ${event.id}');
        emit(
            TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
      }
    } catch (e) {
      print('Error toggling notification: $e');
      emit(TodoLoaded(List.from(_todos), _currentUserName, isFromCache: true));
    }
  }

  Future<void> _onResetTodos(ResetTodos event, Emitter<TodoState> emit) async {
    _todos.clear();
    _currentUserName = 'User';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_todos');
    await prefs.remove('user_name');
    await _notificationService.cancelAllNotifications();
    print('Emitting TodoInitial after reset');
    emit(TodoInitial());
  }
}
