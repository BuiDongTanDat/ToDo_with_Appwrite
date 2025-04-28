import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../model/TodoModel.dart';
import '../theme/color.dart';
import '../widgets/DeleteConfirmDialog.dart';
import '../widgets/MyCustomScrollBehavior.dart';
import '../widgets/ToDoCard.dart';
import 'AddToDoPage.dart';

// Main page
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Chọn ngày
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

  // Hàm xóa filter
  void _clearDateFilter() => setState(() => _selectedDate = null);

  // Hàm nhóm công việc theo ngày
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
          labelStyle: TextStyle(
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
                return Center(child: Text(state.message));
              } else if (state is TodoLoaded) {
                // Apply date filter first
                final filteredTodos = _selectedDate == null
                    ? state.todos
                    : state.todos.where((todo) {
                        final date = DateTime(todo.dueDate.year,
                            todo.dueDate.month, todo.dueDate.day);
                        return date == _selectedDate;
                      }).toList();

                // Filter tasks for each tab
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
                      _buildTabContent(
                          allTasks, 'Yay! Bạn chưa có công việc nào.'),
                      _buildTabContent(
                          completedTasks, 'Chưa có công việc nào hoàn thành!'),
                      _buildTabContent(
                          notCompletedTasks, 'Yay! Bạn chưa có công việc nào!'),
                    ],
                  ),
                );
              }
              return const Center(child: Text('No tasks available'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(List<TodoModel> todos, String emptyMessage) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
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
      },
      future: null,
    );
  }

  // Build Section Header
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

  // Hiển thị công việc
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
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => DeleteConfirmationDialog(
                    todoId: todo.id,
                    onDelete: () {
                      context.read<TodoBloc>().add(DeleteTodo(todo.id));
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
        onToggleComplete: (value) {
          context
              .read<TodoBloc>()
              .add(ToggleTodoCompletion(todo.id, value ?? false));
        },
        onToggleNotification: (value) {
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
              onSaveTask: (updatedTask) =>
                  context.read<TodoBloc>().add(UpdateTodo(updatedTask)),
              initialTask: todo,
            ),
          ),
        ),
      ),
    );
  }

  // Hiển thị trạng thái không có công việc
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
              : 'No tasks for ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

// Header with filter and clear buttons
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