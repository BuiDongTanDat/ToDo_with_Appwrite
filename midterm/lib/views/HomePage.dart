import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../model/ToDo.dart';
import '../theme/color.dart';
import '../widgets/ToDoCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<ToDo> _todos = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Add sample tasks
    _todos.addAll([
      ToDo(
        id: '1',
        title: 'Buy groceries',
        dueDate: DateTime.now(),
        color: 'green',
        isNotified: true,
      ),
      ToDo(
        id: '2',
        title: 'Finish report',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        color: 'blue',
      ),
      ToDo(
        id: '3',
        title: 'Call mom',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        color: 'red',
      ),
    ]);
  }

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _todos.add(ToDo(
          id: Random().nextInt(10000).toString(),
          title: _controller.text,
          dueDate: DateTime.now(),
          color: ['red', 'blue', 'green'][Random().nextInt(3)],
        ));
        _controller.clear();
      });
    }
  }

  void _toggleTaskCompletion(String id, bool? value) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = ToDo(
          id: _todos[index].id,
          title: _todos[index].title,
          dueDate: _todos[index].dueDate,
          isCompleted: value ?? false,
          color: _todos[index].color,
          isNotified: _todos[index].isNotified,
        );
      }
    });
  }

  void _toggleNotification(String id, bool? value) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = ToDo(
          id: _todos[index].id,
          title: _todos[index].title,
          dueDate: _todos[index].dueDate,
          isCompleted: _todos[index].isCompleted,
          color: _todos[index].color,
          isNotified: value ?? false,
        );
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  List<ToDo> _getTodayAndTomorrowTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return _todos.where((todo) {
      final taskDate =
          DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
      return taskDate == today || taskDate == tomorrow;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _currentIndex == 0 ? _getTodayAndTomorrowTasks() : _todos;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Hello',
                                style: TextStyle(
                                  fontSize: 14,
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
                            backgroundImage: AssetImage('assets/avatar.png'),
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

          const SizedBox(height: 20), 
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Image.asset(
                  'assets/Clipboard.png',
                  width: 24,
                  height: 24,
                  
                ),
                const SizedBox(width: 5),
                Text(
                  _currentIndex == 0 ? 'Today & Tomorrow' : 'All Tasks',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorGreen,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'No tasks yet! Add one above.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
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
                              color: Colors
                                  .transparent, // Để giữ nguyên màu nền của Container
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    50), // Match với Container border radius
                                onTap: () {
                                  _deleteTask(todo.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Task deleted!'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.textColorRed.withOpacity(0.2),
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
                            )
                          ],
                        ),
                        child: ToDoCard(
                          todo: todo,
                          onToggleComplete: (value) =>
                              _toggleTaskCompletion(todo.id, value),
                          onToggleNotification: (value) =>
                              _toggleNotification(todo.id, value),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.textColorGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/Home.png'),
              size: 24,
              
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/Edit.png'),
              size: 24,
              
            ),
            label: 'Tasks',
            
          ),
        ],
      ),
    );
  }
}
