import 'package:flutter/material.dart';
import '../backend/appwrite_config.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({Key? key}) : super(key: key);

  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  // Hàm xác thực user khi nhấn nút
  Future<void> _verifyUser(String userId, String secret) async {
    try {
      // Gọi phương thức updateVerification() của Appwrite để xác thực user
      await account.updateVerification(
        userId: userId,
        secret: secret,
      );
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực thành công!')),
      );
    } catch (e) {
      // Hiển thị thông báo lỗi nếu có
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xác thực: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin từ query params (userId và secret) từ URL
    final uri = ModalRoute.of(context)!.settings.arguments as Uri;
    final userId = uri.queryParameters['userId']!;
    final secret = uri.queryParameters['secret']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác Thực Email'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Gọi hàm _verifyUser khi bấm nút
            _verifyUser(userId, secret);
          },
          child: const Text('Xác Thực Thành Công'),
        ),
      ),
    );
  }
}
