//dev_05.dart (작업자 : 정진석)

import 'package:flutter/material.dart';
import 'package:shoes_shop_app/view/main/Admin/auth/admin_profile_edit_view.dart';
import 'package:shoes_shop_app/view/main/Admin/auth/admin_drawer_menu.dart';
import 'package:shoes_shop_app/view/user/auth/user_drawer_menu.dart';
// 정진석님이 만든 페이지들 import

class Dev_05 extends StatefulWidget {
  const Dev_05({super.key});

  @override
  State<Dev_05> createState() => _Dev_05State();
}

class _Dev_05State extends State<Dev_05> {

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("정진석 페이지"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // User Drawer Menu 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserDrawerMenu(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("User Drawer Menu"),
            ),
            const SizedBox(height: 20),
            
            // Admin Drawer Menu 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDrawerMenu(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Admin Drawer Menu"),
            ),
            const SizedBox(height: 20),
            
            // Admin Profile Edit 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminProfileEditView(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Admin Profile Edit"),
            ),
          ],
        ),
      ),
    );
  }
}