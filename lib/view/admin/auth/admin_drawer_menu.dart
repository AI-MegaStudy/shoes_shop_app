import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';

class AdminDrawerMenu extends StatefulWidget {
  const AdminDrawerMenu({super.key});

  @override
  State<AdminDrawerMenu> createState() => _AdminDrawerMenuState();
}

class _AdminDrawerMenuState extends State<AdminDrawerMenu> {
  String _adminName = '관리자';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  /// 관리자 정보 로드
  void _loadAdminInfo() {
    try {
      final storage = GetStorage();
      // GetStorage에서 'admin' 키로 저장된 데이터 로드
      final adminJson = storage.read<String>('admin');
      if (adminJson != null) {
        final admin = jsonDecode(adminJson);
        setState(() {
          // 기존 필드명 사용: e_name, e_email (employee)
          _adminName = admin['e_name'] ?? admin['name'] ?? '관리자';
          _adminEmail = admin['e_email'] ?? admin['email'] ?? '';
        });
      }
    } catch (e) {
      // 에러 발생 시 기본값 유지
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        
        return Drawer(
          child: Container(
            color: p.background,
            child: SafeArea(
              child: Column(
                children: [
                  // 관리자 프로필 헤더
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: p.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 40,
                            color: p.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _adminName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _adminEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 메뉴 목록
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        // 주문 관리 (담당: 임소연)
                        _buildMenuItem(
                          context,
                          icon: Icons.shopping_cart,
                          title: '주문 관리',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: 관리자-주문목록 조회 화면으로 이동 (담당: 임소연)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('주문 관리 화면 준비 중')),
                            );
                          },
                        ),
                        
                        // 반품 관리 (담당: 임소연)
                        _buildMenuItem(
                          context,
                          icon: Icons.assignment_return,
                          title: '반품 관리',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: 관리자-반품목록 조회 화면으로 이동 (담당: 임소연)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('반품 관리 화면 준비 중')),
                            );
                          },
                        ),
                        
                        // 재고 관리
                        _buildMenuItem(
                          context,
                          icon: Icons.inventory,
                          title: '재고 관리',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('재고 관리 화면 준비 중')),
                            );
                          },
                        ),
                        
                        // 고객 관리
                        _buildMenuItem(
                          context,
                          icon: Icons.people,
                          title: '고객 관리',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('고객 관리 화면 준비 중')),
                            );
                          },
                        ),
                        
                        const Divider(height: 24),
                        
                        // 개인정보 수정 (담당: 정진석)
                        _buildMenuItem(
                          context,
                          icon: Icons.person,
                          title: '개인정보 수정',
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToProfileEdit();
                          },
                        ),
                        
                        // 설정
                        _buildMenuItem(
                          context,
                          icon: Icons.settings,
                          title: '설정',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('설정 화면 준비 중')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // 로그아웃 버튼
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _handleLogout,
                        child: const Text(
                          '로그아웃',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 메뉴 아이템 빌더
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final p = context.palette;
    
    return ListTile(
      leading: Icon(icon, color: p.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: p.textPrimary,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// 개인정보 수정 화면으로 이동
  void _navigateToProfileEdit() {
    // TODO: AdminProfileEditView로 이동
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const AdminProfileEditView()),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('개인정보 수정 화면 준비 중')),
    );
  }

  /// 로그아웃 처리
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final storage = GetStorage();
              storage.remove('admin'); // 'admin' 키 사용
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그아웃되었습니다.')),
              );
              
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}