import 'package:flutter/material.dart';

import '../theme/color.dart';
// Delete Confirmation Dialog
class DeleteConfirmationDialog extends StatelessWidget {
  final String todoId;
  final VoidCallback onDelete;

  const DeleteConfirmationDialog({
    super.key,
    required this.todoId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
          child: const Text('Hủy', style: TextStyle(color: AppColors.textColorGrey, fontSize: 16)),
        ),
        TextButton(
          onPressed: () {
            onDelete();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task deleted!'), duration: Duration(seconds: 1)),
            );
          },
          child: const Text('Xóa', style: TextStyle(color: AppColors.textColorRed, fontSize: 16)),
        ),
      ],
    );
  }
}