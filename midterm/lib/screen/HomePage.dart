import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../model/TodoModel.dart';
import '../theme/color.dart';
import '../widgets/ToDoCard.dart';
import 'AddToDoPage.dart';
import 'TasksPage.dart';
import '../widgets/DeleteConfirmDialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc()..add(LoadTodos()),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          body: _currentIndex == 0
              ? Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: BlocBuilder<TodoBloc, TodoState>(
                        builder: (context, state) {
                          if (state is TodoLoading) {
                            return _buildLoadingState();
                          } else if (state is TodoError) {
                            return Center(child: Text(state.message));
                          } else if (state is TodoLoaded) {
                            return _buildTaskLists(state.todos);
                          }
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: const Center(
                                child: Text('Không có công việc nào!')),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : const TasksPage(),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Xin chào',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Tan Dat',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const ImageIcon(
                          AssetImage('assets/Off.png'),
                          size: 24,
                          color: Colors.red,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.lightGreen,
            strokeWidth: 1,
          ),
          SizedBox(height: 10),
          Text(
            'Chờ xíu nha ...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskLists(List<TodoModel> todos) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            _buildTitle(
              title: 'Công việc hôm nay - ${dateFormat.format(today)}',
              titleColor: Colors.black,
              tasks: _getTasksForDate(todos, today),
              context: context,
            ),
            const SizedBox(height: 20),
            _buildTitle(
              title: 'Công việc ngày mai - ${dateFormat.format(tomorrow)}',
              titleColor: Colors.black,
              tasks: _getTasksForDate(todos, tomorrow),
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  List<TodoModel> _getTasksForDate(List<TodoModel> todos, DateTime date) {
    return todos.where((todo) {
      final taskDate =
          DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
      return taskDate == date;
    }).toList();
  }

  Widget _buildTitle({
    required String title,
    required Color titleColor,
    required List<TodoModel> tasks,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
              shadows: [
                Shadow(
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        tasks.isEmpty
            ? Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Không có công việc nào!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final todo = tasks[index];
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
                                  onDelete: () => context
                                      .read<TodoBloc>()
                                      .add(DeleteTodo(todo.id)),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.textColorRed.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Image.asset(
                                'assets/Trash.png',
                                width: 24,
                                height: 24,
                                color: AppColors.textColorRed,
                              ),
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
                        context.read<TodoBloc>().add(
                            ToggleTodoNotification(todo.id, value ?? false));
                      },
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddToDoPage(
                              onSaveTask: (TodoModel updatedTask) {
                                context
                                    .read<TodoBloc>()
                                    .add(UpdateTodo(updatedTask));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task updated!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              initialTask: todo,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                iconPath: 'assets/Home.png',
                label: 'Home',
              ),
              const SizedBox(width: 60),
              _buildNavItem(
                index: 1,
                iconPath: 'assets/Edit.png',
                label: 'Tasks',
              ),
            ],
          ),
          Positioned(
            child: StatefulBuilder(
              builder: (context, setState) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddToDoPage(
                          onSaveTask: (TodoModel newTask) {
                            context.read<TodoBloc>().add(AddTodo(newTask));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Task added!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  onHover: (isHovering) {
                    setState(() {
                      _isHovering = isHovering;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isHovering
                            ? [
                                AppColors.lightGreen,
                                AppColors.lightYellow,
                              ]
                            : [
                                Colors.teal,
                                Colors.teal,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/Note-add.png',
                      width: _isHovering ? 35 : 30,
                      height: _isHovering ? 35 : 30,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String iconPath,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return isSelected
                      ? LinearGradient(
                          colors: [
                            AppColors.lightGreen,
                            AppColors.lightYellow,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds)
                      : const LinearGradient(
                          colors: [Colors.grey, Colors.grey],
                        ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Image.asset(
                  iconPath,
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isSelected ? 16 : 0,
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.lightGreen,
                              AppColors.lightYellow,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds)
                        : const LinearGradient(
                            colors: [Colors.grey, Colors.grey],
                          ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
