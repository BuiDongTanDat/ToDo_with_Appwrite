import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:midterm/service/check_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../model/TodoModel.dart';
import '../theme/color.dart';
import '../widgets/ToDoCard.dart';
import 'AddToDoPage.dart';
import 'TasksPage.dart';
import '../widgets/DeleteConfirmDialog.dart';
import 'Login.dart';
import '../backend/controllers/AuthController.dart';

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isHovering = false;
  bool _isLoading = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      final userEmail = prefs.getString('user_email');
      final userName = prefs.getString('user_name') ?? '';

      if (sessionId == null || userEmail == null) {
        print('No session found, redirecting to LoginPage');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
        return;
      }

      // Kiểm tra kết nối mạng
      bool isConnected = await _checkNetworkConnectivity();
      if (isConnected) {
        final result = await checkLoggedIn(userEmail);
        if (result['code'] == 200) {
          setState(() {
            _userName = (result['response'] as User).name;
          });
          context.read<TodoBloc>().add(LoadTodos());
        } else {
          print('Session invalid: ${result['response']}');
          await prefs.remove('session_id');
          await prefs.remove('user_email');
          await prefs.remove('user_name');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        }
      } else {
        setState(() {
          _userName = userName; // Hiển thị userName lưu trong reference
        });
        context.read<TodoBloc>().add(LoadTodos());
      }
    } catch (e) {
      print('Error checking session: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xác thực người dùng.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      // Vẫn load từ cache ngay cả khi có lỗi
      context.read<TodoBloc>().add(LoadTodos());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Hàm kiểm tra kết nối mạng
  Future<bool> _checkNetworkConnectivity() async {
    return await checkNetworkConnectivity();
  }

  Future<bool> _handleLogout() async {
    print('Starting logout process...');
    setState(() {
      _isLoading = true;
    });

    try {
      print('Calling logout function...');
      final result = await logout();
      print('Logout result: $result');

      if (result['code'] == 204) {
        print('Clearing SharedPreferences...');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('session_id');
        await prefs.remove('user_email');
        await prefs.remove('user_name');
        print('SharedPreferences cleared.');

        context.read<TodoBloc>().add(ResetTodos());
        return true;
      } else {
        print('Logout failed: ${result['response']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng xuất thất bại: ${result['response']}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return false;
      }
    } catch (e) {
      print('Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng xuất: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    } finally {
      print('Hiding loading indicator...');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool?> _showLogoutConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Xác nhận đăng xuất',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorRed,
          ),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất không?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: AppColors.textColorGrey,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final success = await _handleLogout();
              Navigator.pop(context, success);
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.textColorRed,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF0F4F8),
              body: _currentIndex == 0
                  ? Column(
                      children: [
                        _buildHeader(),
                        Expanded(child: _buildTaskContent()),
                      ],
                    )
                  : const TasksPage(),
              bottomNavigationBar: _buildBottomNavigationBar(context),
            ),
          ),
          if (_isLoading)
            AbsorbPointer(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.lightGreen,
                          strokeWidth: 1,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Chờ chút nha ...',
                          style: TextStyle(
                            color: AppColors.lightGreen,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        String displayUserName = widget.userName; // Fallback
        if (state is TodoLoaded) {
          displayUserName = state.userName;
        }
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
                          children: [
                            const Text(
                              'Xin chào',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              displayUserName,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    final shouldLogout =
                                        await _showLogoutConfirmationDialog();
                                    if (shouldLogout == true && mounted) {
                                      print('Logout confirmed and completed.');
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()),
                                      );
                                    } else {
                                      print('Logout cancelled or failed.');
                                    }
                                  },
                            icon: const ImageIcon(
                              AssetImage('assets/Off.png'),
                              size: 24,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskContent() {
    return BlocListener<TodoBloc, TodoState>(
      listener: (context, state) {
        if (state is TodoSessionExpired) {
          print('Session expired, redirecting to LoginPage');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else if (state is TodoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading) {
            return _buildTaskLists([]);
          } else if (state is TodoLoaded) {
            return _buildTaskLists(state.todos);
          } else if (state is TodoError) {
            return _buildTaskLists(state.cachedTodos ?? []);
          }
          return const Center(child: Text('Khởi tạo danh sách công việc...'));
        },
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
      final targetDate = DateTime(date.year, date.month, date.day);
      return taskDate.isAtSameMomentAs(targetDate);
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
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                            onTap: () async {
                              // Kiểm tra kết nối mạng trước khi xóa
                              bool isConnected =
                                  await _checkNetworkConnectivity();
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
                                    print(
                                        'Dispatching DeleteTodo for ID: ${todo.id}');
                                    context
                                        .read<TodoBloc>()
                                        .add(DeleteTodo(todo.id));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Công việc đã được xóa!'),
                                        backgroundColor: Colors.green,
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
                      onToggleComplete: (value) async {
                        // Kiểm tra kết nối mạng trước khi toggle complete
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
                        context
                            .read<TodoBloc>()
                            .add(ToggleTodoCompletion(todo.id, value ?? false));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '"${todo.title}" marked as ${value ?? false ? 'completed' : 'incomplete'}'),
                            backgroundColor: Colors.green,
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
                              content: Text(
                                  'Không có kết nối mạng. Vui lòng kiểm tra kết nối.'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }
                        context.read<TodoBloc>().add(
                            ToggleTodoNotification(todo.id, value ?? false));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Notifications ${value ?? false ? 'enabled' : 'disabled'} for "${todo.title}"'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 1),
                          ),
                        );
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
                                    content:
                                        Text('Công việc đã được cập nhật!'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
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
                                content: Text('Công việc đã được thêm!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
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
