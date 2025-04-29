import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:midterm/service/check_network.dart';
import '../backend/appwrite_config.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../model/TodoModel.dart';
import '../theme/color.dart';
import '../widgets/DeleteConfirmDialog.dart';
import '../widgets/MyCustomScrollBehavior.dart';
import '../widgets/ToDoCard.dart';
import 'AddToDoPage.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  DateTime? _selectedDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load todos ngay khi khởi tạo
    context.read<TodoBloc>().add(LoadTodos());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.lightGreen,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() =>
          _selectedDate = DateTime(picked.year, picked.month, picked.day));
    }
  }

  void _clearDateFilter() => setState(() => _selectedDate = null);

  Map<DateTime, List<TodoModel>> _groupByDate(List<TodoModel> todos) {
    final Map<DateTime, List<TodoModel>> grouped = {};
    for (var todo in todos) {
      final date =
          DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
      grouped.putIfAbsent(date, () => []).add(todo);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TasksHeader(
          selectedDate: _selectedDate,
          onSelectDate: _pickDate,
          onClearDate: _clearDateFilter,
        ),
        const SizedBox(height: 10),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.textColorGreen,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelColor: Colors.grey,
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          indicatorColor: Colors.teal,
          overlayColor: WidgetStateProperty.all(
            Colors.grey.withOpacity(0.2),
          ),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đã hoàn thành'),
            Tab(text: 'Chưa hoàn thành'),
          ],
        ),
        Expanded(
          child: BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              if (state is TodoLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.lightGreen,
                    strokeWidth: 1,
                  ),
                );
              } else if (state is TodoError) {
                // Hiển thị SnackBar cho lỗi và sử dụng cached todos
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor:
                          state.message.contains('Không có kết nối mạng')
                              ? Colors.orange
                              : Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                });
                // Hiển thị danh sách todo từ cache nếu có
                final cachedTodos = state.cachedTodos ?? [];
                return _buildTabView(cachedTodos);
              } else if (state is TodoLoaded) {
                return _buildTabView(state.todos);
              }
              return const Center(
                  child: Text('Yay! Bạn chưa có công việc nào!'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabView(List<TodoModel> todos) {
    final filteredTodos = _selectedDate == null
        ? todos
        : todos.where((todo) {
            final date = DateTime(
                todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
            return date == _selectedDate;
          }).toList();

    final allTasks = filteredTodos;
    final completedTasks =
        filteredTodos.where((todo) => todo.isCompleted).toList();
    final notCompletedTasks =
        filteredTodos.where((todo) => !todo.isCompleted).toList();

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(allTasks, 'Yay! Bạn chưa có công việc nào.'),
          _buildTabContent(completedTasks, 'Chưa có công việc nào hoàn thành!'),
          _buildTabContent(
              notCompletedTasks, 'Yay! Bạn chưa có công việc nào!'),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<TodoModel> todos, String emptyMessage) {
    if (todos.isEmpty) {
      return _emptyStateMessage(emptyMessage);
    }

    final groupedTodos = _groupByDate(todos);
    final dates = groupedTodos.keys.toList()..sort();

    return ListView.builder(
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final todosForDate = groupedTodos[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(DateFormat('dd/MM/yyyy').format(date)),
            ...todosForDate.map((todo) => _todoItem(todo)),
          ],
        );
      },
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Future<bool> _checkNetworkConnectivity() async {
    return await checkNetworkConnectivity();
  }

  Widget _todoItem(TodoModel todo) {
    return Slidable(
      key: ValueKey(todo.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.15,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () async {
                // Kiểm tra kết nối mạng trước khi xóa
                bool isConnected = await _checkNetworkConnectivity();
                if (!isConnected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Không có kết nối mạng. Vui lòng kiểm tra kết nối.'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                showDialog(
                  context: context,
                  builder: (context) => DeleteConfirmationDialog(
                    todoId: todo.id,
                    onDelete: () {
                      context.read<TodoBloc>().add(DeleteTodo(todo.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Công việc đã được xóa!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.textColorRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Image.asset('assets/Trash.png',
                    width: 24, height: 24, color: AppColors.textColorRed),
              ),
            ),
          ),
        ],
      ),
      child: ToDoCard(
        todo: todo,
        onToggleComplete: (value) async {
          // Kiểm tra kết nối mạng trước khi toggle complete
          bool isConnected = await _checkNetworkConnectivity();
          if (!isConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Không có kết nối mạng. Vui lòng kiểm tra kết nối.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }
          context
              .read<TodoBloc>()
              .add(ToggleTodoCompletion(todo.id, value ?? false));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '"${todo.title}" marked as ${value ?? false ? 'completed' : 'incomplete'}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        onToggleNotification: (value) async {
          // Kiểm tra kết nối mạng trước khi toggle notification
          bool isConnected = await _checkNetworkConnectivity();
          if (!isConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Không có kết nối mạng. Vui lòng kiểm tra kết nối.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }
          final account = Account(client);
          final user = await account.get();
          final userId = user.$id;

          final newNotificationDate = value ?? false
              ? (todo.notificationDate ??
                  todo.dueDate.subtract(const Duration(hours: 24)))
              : null;
          final updatedTodo = TodoModel(
            id: todo.id,
            title: todo.title,
            description: todo.description,
            dueDate: todo.dueDate,
            color: todo.color,
            isCompleted: todo.isCompleted,
            isNotified: value ?? false,
            notificationDate: newNotificationDate,
            userId: userId,
          );
          context.read<TodoBloc>().add(UpdateTodo(updatedTodo));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Notifications ${value ?? false ? 'enabled' : 'disabled'} for "${todo.title}"'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        onEdit: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddToDoPage(
              onSaveTask: (updatedTask) {
                context.read<TodoBloc>().add(UpdateTodo(updatedTask));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Công việc đã được cập nhật!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              initialTask: todo,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyStateMessage(String message) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          _selectedDate == null
              ? message
              : 'Không có công việc ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

class TasksHeader extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onSelectDate;
  final VoidCallback onClearDate;

  const TasksHeader({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedDate == null
                ? 'TẤT CẢ CÔNG VIỆC'
                : 'CÔNG VIỆC NGÀY\n${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              _iconButton(
                icon: const ImageIcon(AssetImage('assets/Filter.png')),
                color: AppColors.textColorBlue,
                onPressed: onSelectDate,
              ),
              if (selectedDate != null) const SizedBox(width: 10),
              if (selectedDate != null)
                _iconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: onClearDate,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(
      {required Widget icon, required VoidCallback onPressed, Color? color}) {
    return Container(
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(
        padding: EdgeInsets.zero,
        splashRadius: 0.1,
        icon: icon is ImageIcon
            ? ImageIcon(icon.image, size: 24, color: color)
            : icon,
        onPressed: onPressed,
      ),
    );
  }
}
