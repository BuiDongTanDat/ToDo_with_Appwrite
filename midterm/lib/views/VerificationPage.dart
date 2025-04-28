import 'package:flutter/material.dart';

class VerifyPage extends StatelessWidget {
  const VerifyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy các query parameters từ URL
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
            // Gọi API xác thực (sử dụng userId và secret)
            _verifyEmail(userId, secret);
          },
          child: const Text('Xác Thực Thành Công'),
        ),
      ),
    );
  }

  // Hàm xác thực email (sử dụng Appwrite hoặc API bạn muốn)
  void _verifyEmail(String userId, String secret) {
    // Thực hiện gọi API xác thực ở đây
    print('Xác thực thành công với userId: $userId và secret: $secret');
  }
}
