import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chủ'),
         backgroundColor: Colors.white,
         foregroundColor: Colors.grey.shade800, // Màu chữ và icon trên AppBar
         elevation: 1, // Thêm đường viền nhẹ
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await _auth.signOut();
              // AuthWrapper sẽ tự động chuyển về LoginScreen
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chào mừng!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10),
            if (user?.email != null)
              Text('Đăng nhập với email: ${user!.email}'),
              SizedBox(height: 5),
            if (user?.uid != null)
              Text('User ID: ${user!.uid}', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}