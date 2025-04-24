import 'package:flutter/material.dart';
import '../theme/color.dart';
import '../widgets/CustomInputField.dart';
import 'Register.dart';


class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginPage({super.key});

  Future<void> _login(BuildContext context) async {
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }

    // String username = _usernameController.text.trim();
    // String password = _passwordController.text.trim();

    // DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");

    // try {
    //   DatabaseEvent event = await usersRef.once();
    //   final data = event.snapshot.value as Map<dynamic, dynamic>?;

    //   if (data != null) {
    //     bool found = false;
    //     String foundUserId = '';

    //     data.forEach((key, value) {
    //       if (value["username"] == username && value["password"] == password) {
    //         found = true;
    //         foundUserId = key;
    //       }
    //     });

    //     if (found) {
    //       SharedPreferences prefs = await SharedPreferences.getInstance();
    //       await prefs.setString('userId', foundUserId);

    //       await _saveUserLocation(foundUserId);

    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(builder: (context) => HomePage()),
    //       );
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Sai tài khoản hoặc mật khẩu')),
    //       );
    //     }
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Không tìm thấy dữ liệu người dùng')),
    //     );
    //   }
    // } catch (e) {
    //   debugPrint('Login error: $e');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Đã xảy ra lỗi khi đăng nhập: $e')),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height / 2, // Chiếm nửa trên màn hình
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg2.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 400, // Giới hạn chiều rộng tối đa
                  maxHeight: 600, // Giới hạn chiều cao tối đa
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 20,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'ĐĂNG NHẬP',
                                  style: TextStyle(
                                    fontSize: 16, // Giảm từ 32 xuống 12
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColorBlue,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                CustomInputField(
                                  controller: _usernameController,
                                  hintText: 'Username',
                                  
                                  icon: Icons.person,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng nhập tên đăng nhập';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomInputField(
                                  controller: _passwordController,
                                  hintText: 'Password',
                                  
                                  icon: Icons.lock,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập mật khẩu';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40, // Giảm chiều cao nút
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.textColorBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => _login(context),
                                    child: const Text(
                                      'Đăng nhập',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12, // Giảm kích thước chữ
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()),
                            );
                          },
                          child: Text(
                            'Chưa có tài khoản? Đăng ký ngay',
                            style: TextStyle(
                              color: AppColors.textColorGreen,
                              fontSize: 10, // Giảm từ 14 xuống 10
                            ),
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
      ),
    );
  }
}