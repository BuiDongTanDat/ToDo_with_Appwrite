import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../model/ToDo.dart';
import '../theme/color.dart';
import '../widgets/ToDoCard.dart';

class TasksPage extends StatelessWidget {
  final List<ToDo> todos;
  final Function(String, bool?) onToggleComplete;
  final Function(String, bool?) onToggleNotification;
  final Function(String) onDeleteTask;

  const TasksPage({
    super.key,
    required this.todos,
    required this.onToggleComplete,
    required this.onToggleNotification,
    required this.onDeleteTask,
  });

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
          child: todos.isEmpty
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
                                onDeleteTask(todo.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task deleted!'),
                                    duration: Duration(seconds: 1),
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
                        onToggleComplete: (value) =>
                            onToggleComplete(todo.id, value),
                        onToggleNotification: (value) =>
                            onToggleNotification(todo.id, value),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}