import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/ToDo.dart';
import '../theme/color.dart';

class ToDoCard extends StatefulWidget {
  final ToDo todo;
  final Function(bool?) onToggleComplete;
  final Function(bool?) onToggleNotification;
  final VoidCallback? onEdit; // Thêm callback onEdit

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
      onTap: widget.onEdit, // Gọi onEdit khi nhấn vào card
      child: Container(
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
              height: 50,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    // Circular Checkbox
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSelected = !_isSelected; // Toggle border
                        });
                        widget.onToggleComplete(!widget.todo.isCompleted);
                      },
                      child: Container(
                        width: 16,
                        height: 16,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.todo.isCompleted
                              ? _getColor().withOpacity(0.2)
                              : Colors.white,
                          border: Border.all(
                            color: widget.todo.isCompleted
                                ? Colors.transparent
                                : AppColors.textColorGrey,
                            width: 0.7,
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
                    // Time (Due Date)
                    Container(
                      width: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('HH:mm').format(widget.todo.dueDate),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textColorGrey,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(widget.todo.dueDate),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textColorGrey,
                            ),
                          ),
                        ],
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
                              fontSize: 12,
                              color: widget.todo.isCompleted ? AppColors.textColorGrey : Colors.black,
                              decoration: widget.todo.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.todo.desc,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textColorGrey,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Notification Toggle
                    Container(
                      width: 20,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => widget.onToggleNotification(!widget.todo.isNotified),
                        child: ImageIcon(
                          const AssetImage('assets/Notification.png'),
                          color: widget.todo.isNotified ? AppColors.textColorGrey : AppColors.textColorYellow,
                          size: 24,
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