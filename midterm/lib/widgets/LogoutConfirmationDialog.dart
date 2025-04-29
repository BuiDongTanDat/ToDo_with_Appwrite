import 'package:flutter/material.dart';
import '../theme/color.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final Future<bool> Function() onLogout;

  const LogoutConfirmationDialog({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
          onPressed: () => Navigator.pop(context, false), // Return false on cancel
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
            final success = await onLogout();
            Navigator.pop(context, success); // Return success status
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
    );
  }
}