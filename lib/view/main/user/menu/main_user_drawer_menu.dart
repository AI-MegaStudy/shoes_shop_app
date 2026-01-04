import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/view/main/config/main_ui_config.dart';
// import 'package:shoes_shop_app/view/main/user/cart/main_cart_view.dart';
import 'package:shoes_shop_app/view/user/payment/gt_user_cart_view.dart';
import 'package:shoes_shop_app/view/main/user/auth/user_profile_edit_view.dart';
// import 'package:shoes_shop_app/view/main/user/order/user_purchase_list.dart';

import 'package:shoes_shop_app/view/user/user_pickup_list.dart';
import 'package:shoes_shop_app/view/user/user_purchase_list.dart';
import 'package:shoes_shop_app/view/user/user_refund_list.dart';
import 'package:shoes_shop_app/view/home.dart';
import 'package:shoes_shop_app/view/main/user/auth/login_view.dart';
import 'package:shoes_shop_app/theme/theme_provider.dart';
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';

/// 메인 페이지용 사용자 드로워 메뉴
class MainUserDrawerMenu extends StatefulWidget {
  const MainUserDrawerMenu({super.key});

  @override
  State<MainUserDrawerMenu> createState() => _MainUserDrawerMenuState();
}

class _MainUserDrawerMenuState extends State<MainUserDrawerMenu> {
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
        debugPrint('❌ [MainUserDrawer] 사용자 정보 로드 에러: $e');
      }
    }
  }

  /// 프로필 이미지 로드
  Future<void> _loadProfileImage(int userSeq) async {
    try {
      final baseUrl = config.getApiBaseUrl();
      final uri = Uri.parse('$baseUrl/api/users/$userSeq/profile_image');
      final response = await http.get(uri);

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _profileImageBytes = response.bodyBytes;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [MainUserDrawer] 프로필 이미지 로드 에러: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    bottomLeft: Radius.circular(mainDefaultSpacing),
                    bottomRight: Radius.circular(mainDefaultSpacing),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: p.cardBackground,
                      child: _buildProfileImage(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getDisplayName(),
                      style: mainAppBarTitleStyle.copyWith(color: p.textOnPrimary),
                    ),
                    const SizedBox(height: 4),
                    if (_currentUser?.uEmail != null)
                      Text(
                        _currentUser?.uEmail ?? '',
                        style: mainBodyTextStyle.copyWith(
                          color: p.textOnPrimary.withOpacity(0.7),
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
                      icon: Icons.shopping_cart,
                      title: '장바구니',
                      onTap: () {
                        Get.back();
                        // Get.to(() => MainCartView());
                        Get.to(() => GTUserCartView());
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.shopping_bag,
                      title: '주문 내역',
                      onTap: () {
                        Get.back();
                        Get.to(() => UserPurchaseList());
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.inventory_2,
                      title: '수령 내역',
                      onTap: () {
                        Get.back();
                        Get.to(() => UserPickupList());
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.assignment_return,
                      title: '반품 내역',
                      onTap: () {
                        Get.back();
                        Get.to(() => UserRefundList());
                      },
                    ),
                    Divider(height: 24, color: p.divider),
                    _buildMenuItem(
                      context,
                      icon: Icons.person,
                      title: '개인정보 수정',
                      onTap: () async {
                        Get.back();
                        final result = await Get.to(() => UserProfileEditView());
                        // 개인정보 수정 후 사용자 정보 다시 로드
                        if (result == true) {
                          _loadUserData();
                        }
                      },
                    ),
                    Divider(height: 24, color: p.divider),
                    _buildThemeSwitch(context),
                    Divider(height: 24, color: p.divider),
                    _buildMenuItem(
                      context,
                      icon: Icons.bug_report,
                      title: '테스트 페이지',
                      onTap: () {
                        Get.back();
                        Get.to(() => Home());
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
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: p.divider),
                    ),
                    child: Text(
                      '로그아웃',
                      style: mainMediumTitleStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: p.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 표시할 이름 반환 (이름이 있으면 이름, 없으면 이메일)
  String _getDisplayName() {
    final userName = _currentUser?.uName;
    if (userName != null && userName.trim().isNotEmpty) {
      return userName;
    }
    return _currentUser?.uEmail ?? '고객님';
  }

  /// 프로필 이미지 위젯
  Widget _buildProfileImage(BuildContext context) {
    final p = context.palette;
    
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
    // 프로필 이미지가 없거나 로드되지 않은 경우 이니셜 표시
    final displayName = _getDisplayName();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    return Text(
      initial,
      style: mainLargeTitleStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: p.primary,
      ),
    );
  }

  /// 메뉴 아이템 위젯
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
        style: mainMediumTitleStyle.copyWith(
          fontWeight: FontWeight.w500,
          color: p.textPrimary,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// 테마 선택 스위치 위젯
  Widget _buildThemeSwitch(BuildContext context) {
    final p = context.palette;
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: p.primary,
      ),
      title: Text(
        '다크 모드',
        style: mainMediumTitleStyle.copyWith(
          fontWeight: FontWeight.w500,
          color: p.textPrimary,
        ),
      ),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (value) {
          context.toggleTheme();
        },
        activeThumbColor: p.primary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// 로그아웃 처리
  void _handleLogout() {
    CustomCommonUtil.showConfirmDialog(
      context: context,
      title: '로그아웃',
      message: '정말 로그아웃 하시겠습니까?',
      confirmText: '확인',
      cancelText: '취소',
      onConfirm: () {
        final storage = GetStorage();
        storage.remove('user');
        storage.remove('user_auth_identity');

        // 다이얼로그가 닫힌 후 네비게이션 (다음 프레임에서 실행)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LoginView());
        });
      },
    );
  }
}
