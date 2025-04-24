import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../model/TodoModel.dart';
import '../theme/color.dart';
import '../widgets/ToDoCard.dart';
import 'AddToDoPage.dart';
import 'TasksPage.dart';

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
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        body: _currentIndex == 0
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  const CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        AssetImage('assets/avatar.png'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/Setting.png',
                                  width: 20,
                                  height: 20,
                                  color: AppColors.textColorGrey,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/Off.png',
                                  width: 20,
                                  height: 20,
                                  color: Colors.red,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: BlocBuilder<TodoBloc, TodoState>(
                      builder: (context, state) {
                        if (state is TodoLoading) {
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
                                  'Chờ xíu nha bà...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is TodoError) {
                          return Center(child: Text(state.message));
                        } else if (state is TodoLoaded) {
                          final todos = state.todos;
                          return SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 20),
                                  _buildTitle(
                                    title: 'Công việc hôm nay',
                                    titleColor: Colors.white,
                                    backgroundImage: 'assets/day.png',
                                    tasks: _getTodayTasks(todos),
                                    context: context,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTitle(
                                    title: 'Công việc ngày mai',
                                    titleColor: Colors.white,
                                    backgroundImage: 'assets/night.png',
                                    tasks: _getTomorrowTasks(todos),
                                    context: context,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const Center(child: Text('No tasks available'));
                      },
                    ),
                  ),
                ],
              )
            : const TasksPage(),
        bottomNavigationBar: Container(
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
          padding: const EdgeInsets.all(5),
          height: 70,
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
                      child: Container(
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
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TodoModel> _getTodayTasks(List<TodoModel> todos) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return todos.where((todo) {
      final taskDate =
          DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
      return taskDate == today;
    }).toList();
  }

  List<TodoModel> _getTomorrowTasks(List<TodoModel> todos) {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    return todos.where((todo) {
      final taskDate =
          DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
      return taskDate == tomorrow;
    }).toList();
  }

  Widget _buildTitle({
    required String title,
    required Color titleColor,
    required String backgroundImage,
    required List<TodoModel> tasks,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FractionallySizedBox(
          widthFactor: 0.5,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 30,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backgroundImage),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
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
            ],
          ),
        ),
        const SizedBox(height: 10),
        tasks.isEmpty
            ? Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'No tasks for this day!',
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
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: const Text(
                                    'Xác nhận xóa',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColorRed,
                                    ),
                                  ),
                                  content: const Text(
                                    'Bạn có chắc chắn muốn xóa công việc này không?',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Hủy',
                                        style: TextStyle(
                                          color: AppColors.textColorGrey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context
                                            .read<TodoBloc>()
                                            .add(DeleteTodo(todo.id));
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Task deleted!'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Xóa',
                                        style: TextStyle(
                                          color: AppColors.textColorRed,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                width: 16,
                                height: 16,
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
                  width: 24,
                  height: 24,
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
                      fontSize: 8,
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
