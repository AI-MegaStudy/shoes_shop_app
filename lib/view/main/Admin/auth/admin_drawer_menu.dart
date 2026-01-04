import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/theme/theme_provider.dart';
import 'package:shoes_shop_app/model/staff.dart';
import 'package:shoes_shop_app/view/main/config/main_ui_config.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/view/main/Admin/auth/admin_login_view_dev.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_purchase_view.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_pickup_view.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_refund_view.dart';
import 'package:shoes_shop_app/view/main/Admin/auth/admin_profile_edit_view.dart';
import 'package:shoes_shop_app/view/main/Admin/user/admin_user_list_view.dart';
import 'package:shoes_shop_app/view/main/Admin/product/product_management.dart';
import 'package:shoes_shop_app/config.dart' as config;

/// 관리자 드로워 메뉴
/// GetStorage에서 'admin' 키로 저장된 staff 정보를 로드하여 표시합니다.
class AdminDrawerMenu extends StatefulWidget {
  const AdminDrawerMenu({super.key});

  @override
  State<AdminDrawerMenu> createState() => _AdminDrawerMenuState();
}

class _AdminDrawerMenuState extends State<AdminDrawerMenu> {
  Staff? _currentStaff;
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  /// 관리자 정보 로드
  Future<void> _loadAdminInfo() async {
    try {
      final storage = GetStorage();
      // GetStorage에서 'admin' 키로 저장된 데이터 로드
      final adminJson = storage.read<String>('admin');
      if (adminJson != null) {
        final staff = Staff.fromJson(jsonDecode(adminJson));
        setState(() {
          _currentStaff = staff;
        });
        
        // 프로필 이미지 로드
        if (staff.s_seq != null) {
          await _loadProfileImage(staff.s_seq!);
        }
      }
    } catch (e) {
      // 에러 발생 시 기본값 유지
      if (mounted) {
        debugPrint('[AdminDrawer] 관리자 정보 로드 에러: $e');
      }
    }
  }

  /// 프로필 이미지 로드
  Future<void> _loadProfileImage(int staffSeq) async {
    try {
      final baseUrl = config.getApiBaseUrl();
      final uri = Uri.parse('$baseUrl/api/staff/$staffSeq/profile_image');
      final response = await http.get(uri);

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty && mounted) {
        setState(() {
          _profileImageBytes = response.bodyBytes;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AdminDrawer] 프로필 이미지 로드 에러: $e');
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
                  // 관리자 프로필 헤더
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
                          _currentStaff?.s_name ?? '관리자',
                          style: mainAppBarTitleStyle.copyWith(color: p.textOnPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentStaff?.s_id ?? '',
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
                        // 재고 관리 (제품 관리 화면으로 이동)
                        _buildMenuItem(
                          context,
                          icon: Icons.inventory,
                          title: '재고 관리',
                          onTap: () {
                            Get.back();
                            Get.to(() => ProductManagement());
                          },
                        ),
                        
                        // 주문 관리 (담당: 임소연)
                        _buildMenuItem(
                          context,
                          icon: Icons.shopping_cart,
                          title: '주문 관리',
                          onTap: () {
                            Get.back();
                            Get.to(() => AdminPurchaseView());
                          },
                        ),
                        
                        // 수령 관리 (담당: 임소연)
                        _buildMenuItem(
                          context,
                          icon: Icons.inventory_2,
                          title: '수령 관리',
                          onTap: () {
                            Get.back();
                            Get.to(() => AdminPickupView());
                          },
                        ),
                        
                        // 반품 관리 (담당: 임소연)
                        _buildMenuItem(
                          context,
                          icon: Icons.assignment_return,
                          title: '반품 관리',
                          onTap: () {
                            Get.back();
                            Get.to(() => AdminRefundView());
                          },
                        ),
                        
                        // 고객 관리
                        _buildMenuItem(
                          context,
                          icon: Icons.people,
                          title: '고객 관리',
                          onTap: () {
                            Get.back();
                            Get.to(() => AdminUserListView());
                          },
                        ),
                        
                        Divider(height: 24, color: p.divider),
                        
                        // 개인정보 수정 (담당: 정진석)
                        _buildMenuItem(
                          context,
                          icon: Icons.person,
                          title: '개인정보 수정',
                          onTap: () async {
                            Get.back();
                            final result = await Get.to(() => AdminProfileEditView());
                            // 개인정보 수정 후 관리자 정보 다시 로드
                            if (result == true) {
                              _loadAdminInfo();
                            }
                          },
                        ),
                        
                        Divider(height: 24, color: p.divider),
                        
                        // 테마 스위치
                        _buildThemeSwitch(context),
                      ],
                    ),
                  ),
                  
                  // 로그아웃 버튼
                  Padding(
                    padding: mainDefaultPadding,
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
        style: mainMediumTitleStyle.copyWith(
          fontWeight: FontWeight.w500,
          color: p.textPrimary,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: mainSmallBorderRadius,
      ),
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
      onTap: () {
        context.toggleTheme(); // ListTile 탭 시에도 테마 토글
      },
      shape: RoundedRectangleBorder(
        borderRadius: mainSmallBorderRadius,
      ),
    );
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
            return ClipOval(
              child: Image.asset(
                config.defaultProfileImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.admin_panel_settings, size: 40, color: p.primary);
                },
              ),
            );
          },
        ),
      );
    }
    
    // 프로필 이미지가 없거나 로드되지 않은 경우 기본 이미지 표시
    return ClipOval(
      child: Image.asset(
        config.defaultProfileImage,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.admin_panel_settings, size: 40, color: p.primary);
        },
      ),
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
        storage.remove('admin'); // 'admin' 키 사용
        
        // 다이얼로그가 닫힌 후 네비게이션 (다음 프레임에서 실행)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => AdminLoginViewDev());
        });
      },
    );
  }
}

