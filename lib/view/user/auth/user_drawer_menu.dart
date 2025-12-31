import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/view/user/auth/user_profile_edit_view.dart';

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

  /// 사용자 정보 로드 (user 테이블)
  Future<void> _loadUserData() async {
    try {
      final storage = GetStorage();
      final userJson = storage.read<String>('user');
      if (userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        setState(() {
          _currentUser = user;
        });
        
        // 프로필 이미지 로드
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
                        // 프로필 이미지
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
                        // 홈
                        _buildMenuItem(
                          context,
                          icon: Icons.home,
                          title: '홈',
                          subtitle: '메인 화면',
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        
                        // 상품 조회 (담당: 이광태)
                        _buildMenuItem(
                          context,
                          icon: Icons.search,
                          title: '상품 조회',
                          subtitle: '신발 둘러보기',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: 사용자-상품조회 화면으로 이동
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('상품 조회 화면은 준비 중입니다. (담당: 이광태)')),
                            );
                          },
                        ),
                        
                        // 장바구니 (담당: 이예은)
                        _buildMenuItem(
                          context,
                          icon: Icons.shopping_cart,
                          title: '장바구니',
                          subtitle: '담은 상품 보기',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: 사용자-장바구니 화면으로 이동
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('장바구니 화면은 준비 중입니다. (담당: 이예은)')),
                            );
                          },
                        ),
                        
                        // 주문 내역 (담당: 유다원)
                        _buildMenuItem(
                          context,
                          icon: Icons.shopping_bag,
                          title: '주문 내역',
                          subtitle: '내 주문 조회',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: 사용자-주문내역 조회 화면으로 이동
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('주문 내역 화면은 준비 중입니다. (담당: 유다원)')),
                            );
                          },
                        ),
                        
                        // 수령/반품 목록 (담당: 유다원)
                        _buildMenuItem(
                          context,
                          icon: Icons.receipt_long,
                          title: '수령/반품 조회',
                          subtitle: '수령 및 반품 내역',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: 사용자-수령 반품목록 조회 화면으로 이동
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('수령/반품 조회 화면은 준비 중입니다. (담당: 유다원)')),
                            );
                          },
                        ),
                        
                        // 찜 목록
                        _buildMenuItem(
                          context,
                          icon: Icons.favorite,
                          title: '찜 목록',
                          subtitle: '관심 상품',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('찜 목록 화면은 준비 중입니다.')),
                            );
                          },
                        ),
                        
                        // 매장 찾기
                        _buildMenuItem(
                          context,
                          icon: Icons.location_on,
                          title: '매장 찾기',
                          subtitle: '오프라인 지점',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('매장 찾기 화면은 준비 중입니다.')),
                            );
                          },
                        ),
                        
                        // 공지사항 (Firebase - 추가 작업)
                        _buildMenuItem(
                          context,
                          icon: Icons.announcement,
                          title: '공지사항',
                          subtitle: '새로운 소식',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: 사용자-공지 조회 화면으로 이동 (Firebase)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('공지사항 화면은 준비 중입니다. (Firebase)')),
                            );
                          },
                        ),
                        
                        // 고객센터 (Firebase - 추가 작업)
                        _buildMenuItem(
                          context,
                          icon: Icons.chat,
                          title: '고객센터',
                          subtitle: '1:1 상담',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: 사용자-상담 채팅 화면으로 이동 (Firebase)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('고객센터 화면은 준비 중입니다. (Firebase)')),
                            );
                          },
                        ),
                        
                        const Divider(height: 24),
                        
                        // 개인정보 수정 (담당: 정진석)
                        _buildMenuItem(
                          context,
                          icon: Icons.person,
                          title: '개인정보 수정',
                          subtitle: '내 정보 관리',
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

  /// 프로필 이미지 위젯 빌드
  Widget _buildProfileImage(AppColorScheme p) {
    if (_profileImageBytes != null) {
      return ClipOval(
        child: Image.memory(
          _profileImageBytes!,
          fit: BoxFit.cover,
          width: 80,
          height: 80,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: 40,
              color: p.primary,
            );
          },
        ),
      );
    }
    return Icon(
      Icons.person,
      size: 40,
      color: p.primary,
    );
  }

  /// 메뉴 아이템 빌더
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
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
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: p.textSecondary,
              ),
            )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// 개인정보 수정 화면으로 이동
  void _navigateToProfileEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserProfileEditView(),
      ),
    );
    
    // 수정 완료 시 사용자 정보 다시 로드
    if (result == true) {
      await _loadUserData();
    }
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
              storage.remove('user');
              storage.remove('user_auth_identity');
              
              Navigator.pop(context); // 다이얼로그 닫기
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그아웃되었습니다.')),
              );
              
              // 로그인 화면으로 이동
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}