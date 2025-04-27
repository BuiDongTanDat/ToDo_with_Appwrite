import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/TodoModel.dart';
import '../theme/color.dart';

class ToDoCard extends StatefulWidget {
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

  @override
  State<ToDoCard> createState() => _ToDoCardState();
}

class _ToDoCardState extends State<ToDoCard> {
  bool _isSelected = false;

  Color _getColor() {
    switch (widget.todo.color.toLowerCase()) {
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
    return GestureDetector(
      onTap: widget.onEdit,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            color: _isSelected ? _getColor() : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Colored bar
            Container(
              width: 10,
              height: double.infinity,
              decoration: BoxDecoration(
                color: _getColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    // Circular Checkbox
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSelected = !_isSelected;
                        });
                        widget.onToggleComplete(!widget.todo.isCompleted);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.todo.isCompleted
                              ? _getColor().withOpacity(0.2)
                              : Colors.white,
                          border: Border.all(
                            color: widget.todo.isCompleted
                                ? Colors.transparent
                                : _getColor(),
                            width: 0.5,
                          ),
                        ),
                        child: widget.todo.isCompleted
                            ? ImageIcon(
                                const AssetImage('assets/Tick.png'),
                                color: _getColor(),
                                size: 12,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Time (Due Time)
                    Text(
                      DateFormat('HH:mm').format(widget.todo.dueDate),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textColorGrey,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Task Title and Description
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.todo.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.todo.isCompleted
                                  ? AppColors.textColorGrey
                                  : Colors.black,
                              decoration: widget.todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.todo.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textColorGrey,
                              decoration: widget.todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Notification Toggle
                    Container(
                     
                      alignment: Alignment.center,
                      child: IconButton(
                        onPressed: () {
                          widget.onToggleNotification(!widget.todo.isNotified);
                        },
                        splashRadius: 0.1,
                        padding: EdgeInsets.all(0),
                        icon: Image.asset(
                          widget.todo.isNotified
                              ? 'assets/Notification_on.png'
                              : 'assets/Notification.png',
                          width: 30,
                          height: 30,
                          color: widget.todo.isNotified
                              ? null
                              : AppColors.textColorGrey,
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
