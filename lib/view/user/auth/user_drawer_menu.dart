import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/model/user.dart';

class UserDrawerMenu extends StatefulWidget {
  const UserDrawerMenu({super.key});

  @override
  State<UserDrawerMenu> createState() => _UserDrawerMenuState();
}

class _UserDrawerMenuState extends State<UserDrawerMenu> {
  User? _currentUser;
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 사용자 정보 로드
  Future<void> _loadUserData() async {
    try {
      final storage = GetStorage();
      final userJson = storage.read<String>('user');
      if (userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        setState(() {
          _currentUser = user;
        });
        
        if (user.uSeq != null) {
          await _loadProfileImage(user.uSeq!);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserDrawer] 사용자 정보 로드 에러: $e');
      }
    }
  }

  /// 프로필 이미지 로드
  Future<void> _loadProfileImage(int userSeq) async {
    try {
      final uri = Uri.parse('${config.getApiBaseUrl()}/api/users/$userSeq/profile_image');
      final response = await http.get(uri);
      
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _profileImageBytes = response.bodyBytes;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserDrawer] 프로필 이미지 로드 에러: $e');
      }
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
                  // 사용자 프로필 헤더
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
                          child: _buildProfileImage(p),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentUser?.uName ?? '고객님',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentUser?.uEmail ?? '',
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
                        _buildMenuItem(
                          context,
                          icon: Icons.home,
                          title: '홈',
                          onTap: () => Navigator.pop(context),
                        ),
                        
                        // 상품 조회 
                        _buildMenuItem(
                          context,
                          icon: Icons.search,
                          title: '상품 조회',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('상품 조회 화면 준비 중 (담당: 이광태)')),
                            );
                          },
                        ),
                        
                        // 장바구니
                        _buildMenuItem(
                          context,
                          icon: Icons.shopping_cart,
                          title: '장바구니',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('장바구니 화면 준비 중 (담당: 이예은)')),
                            );
                          },
                        ),
                        
                        // 주문 내역
                        _buildMenuItem(
                          context,
                          icon: Icons.shopping_bag,
                          title: '주문 내역',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('주문 내역 화면 준비 중 (담당: 유다원)')),
                            );
                          },
                        ),
                        
                        // 수령/반품 조회
                        _buildMenuItem(
                          context,
                          icon: Icons.receipt_long,
                          title: '수령/반품 조회',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('수령/반품 조회 화면 준비 중 (담당: 유다원)')),
                            );
                          },
                        ),
                        
                        const Divider(height: 24),
                        
                        // 개인정보 수정
                        _buildMenuItem(
                          context,
                          icon: Icons.person,
                          title: '개인정보 수정',
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToProfileEdit();
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

  Widget _buildProfileImage(AppColorScheme p) {
    if (_profileImageBytes != null) {
      return ClipOval(
        child: Image.memory(
          _profileImageBytes!,
          fit: BoxFit.cover,
          width: 80,
          height: 80,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person, size: 40, color: p.primary);
          },
        ),
      );
    }
    return Icon(Icons.person, size: 40, color: p.primary);
  }

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

  void _navigateToProfileEdit() async {
    // TODO: UserProfileEditView로 이동
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const UserProfileEditView()),
    // );
    // if (result == true) await _loadUserData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('개인정보 수정 화면 준비 중')),
    );
  }

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
              storage.remove('user');
              storage.remove('user_auth_identity');
              
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