import 'package:flutter/material.dart';
import '../theme/color.dart';
import '../widgets/CustomInputField.dart';
import 'Login.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  RegisterPage({super.key});

  Future<void> _register(BuildContext context) async {
    // if (!_formKey.currentState!.validate()) return;

    // String username = _usernameController.text.trim();
    // String password = _passwordController.text.trim();

    // DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users/$username");

    // try {
    //   DatabaseEvent event = await userRef.once();

    //   if (event.snapshot.exists) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text("Tên đăng nhập đã tồn tại")),
    //     );
    //     return;
    //   }

    //   await userRef.set({
    //     'username': username,
    //     'password': password,
    //   });

    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Đăng ký thành công!")),
    //   );

    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => LoginPage()),
    //   );
    // } catch (e) {
    //   debugPrint('Register error: $e');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Lỗi khi đăng ký: $e')),
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
                    image: AssetImage('assets/alltask.png'),
                    fit: BoxFit.cover, // Phủ đầy khu vực
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400, // Giới hạn chiều rộng tối đa
                  maxHeight: 650, // Giới hạn chiều cao tối đa
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 20,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'ĐĂNG KÝ',
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
                                const SizedBox(height: 16),
                                CustomInputField(
                                  controller: _confirmController,
                                  hintText: 'Confirm Password',
                                  
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Mật khẩu không khớp';
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
                                    onPressed: () => _register(context),
                                    child: const Text(
                                      'Đăng ký',
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          child: Text(
                            'Đã có tài khoản? Đăng nhập',
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