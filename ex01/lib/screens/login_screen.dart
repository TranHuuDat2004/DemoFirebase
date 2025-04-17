import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true; // Để ẩn/hiện mật khẩu

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // AuthWrapper sẽ xử lý điều hướng khi đăng nhập thành công
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _mapFirebaseAuthException(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi không mong đợi. Vui lòng thử lại.';
      });
    } finally {
       if (mounted) {
           setState(() { _isLoading = false; });
       }
    }
  }

  // Hàm ánh xạ mã lỗi Firebase thành thông báo thân thiện
  String _mapFirebaseAuthException(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password': // Gộp chung để tránh tiết lộ email nào tồn tại
        return 'Email hoặc mật khẩu không chính xác.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      default:
        return 'Đăng nhập thất bại. Vui lòng thử lại.';
    }
  }

   @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Đảm bảo nội dung không bị che bởi tai thỏ, notch,...
        child: Center(
          child: SingleChildScrollView( // Cho phép cuộn khi bàn phím hiện lên
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch, // Kéo dài các thành phần con
                children: <Widget>[
                  // Có thể thêm logo ở đây: Image.asset('assets/google_logo.png', height: 40),
                  Text(
                    'Đăng nhập',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Sử dụng tài khoản của bạn', // Hoặc tương tự
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Vui lòng nhập email hợp lệ';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton( // Nút ẩn/hiện mật khẩu
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Align( // Đặt nút quên mật khẩu sang phải
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Chức năng quên mật khẩu chưa được cài đặt.'))
                        );
                      },
                      child: Text('Quên mật khẩu?'),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _signIn,
                          child: Text('Đăng nhập'),
                        ),
                  SizedBox(height: 25),
                   Row( // Phân tách dòng "Hoặc"
                      children: <Widget>[
                        Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('Hoặc', style: TextStyle(color: Colors.grey.shade600)),
                        ),
                        Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
                      ],
                    ),
                  SizedBox(height: 25),
                  OutlinedButton.icon( // Nút đăng nhập Google (chưa cài đặt logic)
                    icon: Image.asset('img/Google.png', height: 18.0), // Cần có file logo google trong assets
                    label: Text('Đăng nhập bằng Google', style: TextStyle(color: Colors.grey.shade800)),
                    style: OutlinedButton.styleFrom(
                       side: BorderSide(color: Colors.grey.shade400),
                       padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                       // TODO: Implement Google Sign-In
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Chức năng đăng nhập Google chưa được cài đặt.'))
                        );
                    },
                  ),
                   SizedBox(height: 30),
                   TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('Tạo tài khoản mới'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}