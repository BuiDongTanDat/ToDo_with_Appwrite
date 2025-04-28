import 'package:flutter/material.dart';
import 'package:midterm/widgets/CustomElevatedButton.dart';
import 'package:midterm/widgets/CustomOutlineButton.dart';
import '../theme/color.dart';
import '../widgets/CustomInputField.dart';
import 'Login.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ForgotPasswordPage({super.key});

  Future<void> _forgotPassword(BuildContext context) async {
   // TO DO
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
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/bg2.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
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
                                  'QUÊN MẬT KHẨU',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColorBlue,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                CustomInputField(
                                  controller: _emailController,
                                  hintText: 'Nhập email của bạn',
                                  icon: Icons.email,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng nhập email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                CustomElevatedButton(
                                  text: "Gửi liên kết khôi phục",
                                  onPressed: () {
                                    _forgotPassword(context);
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomOutlinedButton(
                          text: "Đã có tài khoản? Đăng nhập",
                          onPressed: () {
                            Navigator.push(context,
                            
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
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
