import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/TodoModel.dart';
import '../theme/color.dart';

class ToDoCard extends StatelessWidget {
  final TodoModel todo;
  final Function(bool?) onToggleComplete;
  final Function(bool?) onToggleNotification;
  final VoidCallback? onEdit;

  const ToDoCard({
    super.key,
    required this.todo,
    required this.onToggleComplete,
    required this.onToggleNotification,
    this.onEdit,
  });

  Color _getColor() {
    switch (todo.color.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            color: todo.isCompleted ? color : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        onToggleComplete(!todo.isCompleted);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: todo.isCompleted
                              ? color.withOpacity(0.2)
                              : Colors.white,
                          border: Border.all(
                            color:
                                todo.isCompleted ? Colors.transparent : color,
                            width: 0.5,
                          ),
                        ),
                        child: todo.isCompleted
                            ? ImageIcon(
                                const AssetImage('assets/Tick.png'),
                                color: color,
                                size: 12,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('HH:mm').format(todo.dueDate),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textColorGrey,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: todo.isCompleted
                                  ? AppColors.textColorGrey
                                  : Colors.black,
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            todo.description ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textColorGrey,
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: IconButton(
                        onPressed: () {
                          onToggleNotification(!todo.isNotified);
                        },
                        splashRadius: 0.1,
                        padding: EdgeInsets.zero,
                        icon: Image.asset(
                          todo.isNotified
                              ? 'assets/Notification_on.png'
                              : 'assets/Notification.png',
                          width: 30,
                          height: 30,
                          color:
                              todo.isNotified ? null : AppColors.textColorGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
