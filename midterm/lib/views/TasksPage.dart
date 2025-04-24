import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../model/ToDo.dart';
import '../theme/color.dart';
import '../widgets/ToDoCard.dart';
import 'AddToDoPage.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Clipboard.png',
                width: 50,
                height: 50,
                fit: BoxFit.scaleDown,
              ),
              Text(
                'TẤT CẢ CÔNG VIỆC',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              if (state is TodoLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TodoError) {
                return Center(child: Text(state.message));
              } else if (state is TodoLoaded) {
                final todos = state.todos;
                return todos.isEmpty
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
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
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
                                                context.read<TodoBloc>().add(DeleteTodo(todo.id));
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(
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
                                context.read<TodoBloc>().add(ToggleTodoCompletion(todo.id, value ?? false));
                              },
                              onToggleNotification: (value) {
                                context.read<TodoBloc>().add(ToggleTodoNotification(todo.id, value ?? false));
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddToDoPage(
                                      onSaveTask: (ToDo updatedTask) {
                                        context.read<TodoBloc>().add(UpdateTodo(updatedTask));
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
                      );
              }
              return const Center(child: Text('No tasks available'));
            },
          ),
        ),
      ],
    );
  }
}