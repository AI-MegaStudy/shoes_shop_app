import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/view/main/user/auth/user_profile_edit_view.dart';
import 'package:shoes_shop_app/view/main/user/auth/login_view.dart';
import 'package:shoes_shop_app/view/main/config/main_ui_config.dart';
import 'package:shoes_shop_app/view/main/user/product/main_product_list.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';


import 'package:shoes_shop_app/view/Dev/dev_01.dart';
import 'package:shoes_shop_app/view/Dev/dev_02.dart';
import 'package:shoes_shop_app/view/Dev/dev_03.dart';
import 'package:shoes_shop_app/view/Dev/dev_04.dart';
import 'package:shoes_shop_app/view/Dev/dev_05.dart';
import 'package:shoes_shop_app/view/Dev/dev_06.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// 현재 사용자 정보
  User? _currentUser;
  
  /// 사용자 정보 로딩 중 상태
  bool _isLoading = true;

  final List<Widget> _devPages = [
    const Dev_01(),
    const Dev_02(),
    const Dev_03(),
    const Dev_04(),
    const Dev_05(),
    const Dev_06(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          backgroundColor: p.background,
          appBar: AppBar(
            title: Text(
              '홈',
              style: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
            ),
            centerTitle: mainAppBarCenterTitle,
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: p.primary),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: mainDefaultPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 사용자 정보 섹션 (있으면 표시, 없으면 에러 메시지)
                        if (_currentUser != null) ...[
                          // 사용자 정보 카드
                          Card(
                            elevation: mainCardElevation,
                            color: p.cardBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: mainDefaultBorderRadius,
                            ),
                            child: Padding(
                              padding: mainDefaultPadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 사용자 정보 제목
                                  Text(
                                    '사용자 정보',
                                    style: mainTitleStyle.copyWith(color: p.textPrimary),
                                  ),
                                  Divider(color: p.divider),
                                  const SizedBox(height: mainSmallSpacing),
                                  
                                  // 이름
                                  _buildInfoRow(
                                    context,
                                    icon: Icons.person,
                                    label: '이름',
                                    value: _currentUser!.uName,
                                  ),
                                  
                                  // 이메일
                                  _buildInfoRow(
                                    context,
                                    icon: Icons.email,
                                    label: '이메일',
                                    value: _currentUser!.uEmail,
                                  ),
                                  
                                  // 전화번호
                                  if (_currentUser!.uPhone != null && _currentUser!.uPhone!.isNotEmpty) ...[
                                    const SizedBox(height: mainSmallSpacing),
                                    _buildInfoRow(
                                      context,
                                      icon: Icons.phone,
                                      label: '전화번호',
                                      value: _currentUser!.uPhone!,
                                    ),
                                  ],
                                  
                                  // 주소
                                  if (_currentUser!.uAddress != null && _currentUser!.uAddress!.isNotEmpty) ...[
                                    const SizedBox(height: mainSmallSpacing),
                                    _buildInfoRow(
                                      context,
                                      icon: Icons.home,
                                      label: '주소',
                                      value: _currentUser!.uAddress!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: mainDefaultSpacing),
                          
                          // 프로필 수정 버튼
                          Center(
                            child: SizedBox(
                              width: mainButtonMaxWidth,
                              height: mainButtonHeight,
                              child: ElevatedButton(
                                onPressed: _navigateToProfileEdit,
                                style: mainPrimaryButtonStyle.copyWith(
                                  backgroundColor: WidgetStateProperty.all(p.primary),
                                  foregroundColor: WidgetStateProperty.all(p.textOnPrimary),
                                ),
                                child: const Text('개인정보 수정'),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: mainSmallSpacing),
                          
                          // 로그아웃 버튼
                          Center(
                            child: SizedBox(
                              width: mainButtonMaxWidth,
                              height: mainButtonHeight,
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
                          
                          const SizedBox(height: mainSmallSpacing),
                          
                          // 메인 상품 리스트 버튼
                          Center(
                            child: SizedBox(
                              width: mainButtonMaxWidth,
                              height: mainButtonHeight,
                              child: ElevatedButton(
                                onPressed: _navigateToMainProductList,
                                style: mainPrimaryButtonStyle.copyWith(
                                  backgroundColor: WidgetStateProperty.all(p.primary),
                                  foregroundColor: WidgetStateProperty.all(p.textOnPrimary),
                                ),
                                child: const Text('메인 상품 리스트'),
                              ),
                            ),
                          ),
                        ] else ...[
                          // 사용자 정보 없을 때 에러 메시지
                          Card(
                            elevation: mainCardElevation,
                            color: p.cardBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: mainDefaultBorderRadius,
                            ),
                            child: Padding(
                              padding: mainDefaultPadding,
                              child: Column(
                                children: [
                                  Icon(Icons.person_off, size: 64, color: p.textSecondary),
                                  const SizedBox(height: mainDefaultSpacing),
                                  Text(
                                    '사용자 정보를 불러올 수 없습니다.',
                                    style: mainBodyTextStyle.copyWith(color: p.textPrimary),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: mainDefaultSpacing),
                                  Center(
                                    child: SizedBox(
                                      width: mainButtonMaxWidth,
                                      height: mainButtonHeight,
                                      child: OutlinedButton(
                                        onPressed: _loadUserData,
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: p.divider),
                                        ),
                                        child: Text(
                                          '다시 시도',
                                          style: mainMediumTitleStyle.copyWith(
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
                        ],

                        // 개발 페이지 버튼 (항상 표시)
                        const SizedBox(height: mainLargeSpacing),
                        ..._buildDevPageButtons(context),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  /// 정보 행 위젯 생성
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final p = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: p.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: mainSmallTextStyle.copyWith(color: p.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: mainMediumTextStyle.copyWith(color: p.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 개발 페이지 버튼 목록 생성
  List<Widget> _buildDevPageButtons(BuildContext context) {
    final p = context.palette;
    return [
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(0),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: p.divider),
            ),
            child: Text(
              '이광태 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      const SizedBox(height: mainSmallSpacing),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(1),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: p.divider),
            ),
            child: Text(
              '이예은 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      const SizedBox(height: mainSmallSpacing),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(2),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: p.divider),
            ),
            child: Text(
              '유다원 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      const SizedBox(height: mainSmallSpacing),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(3),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: p.divider),
            ),
            child: Text(
              '임소연 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      const SizedBox(height: mainSmallSpacing),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(4),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: p.divider),
            ),
            child: Text(
              '정진석 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
      const SizedBox(height: mainSmallSpacing),
      Center(
        child: SizedBox(
          width: mainButtonMaxWidth,
          height: mainButtonHeight,
          child: OutlinedButton(
            onPressed: () => _navigateToDevPage(5),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: p.divider),
            ),
            child: Text(
              '김택권 페이지',
              style: mainMediumTitleStyle.copyWith(color: p.textPrimary),
            ),
          ),
        ),
      ),
    ];
  }

  //--------Functions ------------
  /// GetStorage에서 사용자 정보 로드
  Future<void> _loadUserData() async {
    try {
      final storage = GetStorage();
      final userJson = storage.read<String>('user');
      
      if (userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 프로필 수정 페이지로 이동
  void _navigateToProfileEdit() async {
    final result = await Get.to(() => UserProfileEditView());
    
    // 프로필 수정 후 돌아왔을 때 사용자 정보 새로고침
    if (result == true) {
      _loadUserData();
    }
  }

  /// 개발 페이지로 이동
  void _navigateToDevPage(int index) async {
    await Get.to(() => _devPages[index]);
  }

  /// 로그아웃 처리
  /// GetStorage에서 사용자 정보와 인증 정보를 삭제하고 로그인 화면으로 이동
  void _handleLogout() {
    CustomCommonUtil.showConfirmDialog(
      context: context,
      title: '로그아웃',
      message: '정말 로그아웃 하시겠습니까?',
      confirmText: '로그아웃',
      cancelText: '취소',
      onConfirm: () {
        try {
          final storage = GetStorage();
          
          // GetStorage에서 사용자 정보 삭제
          storage.remove('user');
          storage.remove('user_auth_identity');
        } catch (e) {
          // 에러 무시
        }
        
        // 다이얼로그가 닫힌 후 네비게이션 (다음 프레임에서 실행)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LoginView());
        });
      },
    );
  }

  /// 메인 상품 리스트 페이지로 이동
  void _navigateToMainProductList() {
    Get.to(() => const MainProductList());
  }
  //------------------------------
}