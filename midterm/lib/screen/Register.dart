import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:midterm/backend/controllers/AuthController.dart';
import 'package:midterm/service/check_network.dart';
import 'package:midterm/widgets/CustomElevatedButton.dart';
import 'package:midterm/widgets/CustomOutlineButton.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Add this import
import '../theme/color.dart';
import '../widgets/CustomInputField.dart';
import 'Login.dart';
import 'HomePage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Hàm kiểm tra kết nối mạng
  Future<bool> _checkNetworkConnectivity() async {
    return await checkNetworkConnectivity();
  }

  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Kiểm tra kết nối mạng trước khi đăng ký
    bool isConnected = await _checkNetworkConnectivity();
    if (!isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có kết nối mạng. Vui lòng kiểm tra kết nối.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      Map<String, Object?> result = await register(name, email, password);

      if (result['code'] == 201) {
        // Auto-login after successful registration
        final loginResult = await login(email, password);
        if (loginResult['code'] == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['response'].toString())),
        );
      }
    } on AppwriteException catch (e) {
      String errorMessage = "An error occurred: $e";
      if (e.code == 429) {
        errorMessage =
            "Vui lòng thử lại sau vài phút do vượt quá giới hạn yêu cầu.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: MediaQuery.of(context).size.height / 2,
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
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                        maxHeight: 650,
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
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textColorBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      CustomInputField(
                                        controller: _nameController,
                                        hintText: 'Your name',
                                        icon: Icons.person,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Vui lòng nhập tên';
                                          }
                                          if (value.trim().length < 2) {
                                            return 'Tên phải có ít nhất 2 ký tự';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      CustomInputField(
                                        controller: _emailController,
                                        hintText: 'Email',
                                        icon: Icons.email,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Vui lòng nhập email';
                                          }
                                          if (!RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                              .hasMatch(value)) {
                                            return 'Vui lòng nhập email hợp lệ';
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
                                          if (value.length < 8) {
                                            return 'Mật khẩu phải có ít nhất 8 ký tự';
                                          }
                                          if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)')
                                              .hasMatch(value)) {
                                            return 'Mật khẩu phải chứa cả chữ và số';
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
                                          if (value == null || value.isEmpty) {
                                            return 'Vui lòng xác nhận mật khẩu';
                                          }
                                          if (value != _passwordController.text) {
                                            return 'Mật khẩu không khớp';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      CustomElevatedButton(
                                        text: "Đăng ký",
                                        onPressed: () {
                                          _register(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              CustomOutlinedButton(
                                text: "Đã có tài khoản? Đăng nhập",
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
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
          ),
          if (_isLoading)
            AbsorbPointer(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.textColorBlue,
                          strokeWidth: 1,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Chờ chút nha ...',
                          style: TextStyle(
                            color: AppColors.textColorBlue,
                            fontSize: 12,
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
    );
  }
}