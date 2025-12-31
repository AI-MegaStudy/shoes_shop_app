import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/view/user/auth/user_profile_edit_view.dart';
import 'package:shoes_shop_app/view/user/auth/login_view.dart';
import 'package:shoes_shop_app/view/product_file_upload_view.dart';
import 'package:shoes_shop_app/custom/custom.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

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
    final result = await CustomNavigationUtil.to(
      context,
      const UserProfileEditView(),
    );
    
    // 프로필 수정 후 돌아왔을 때 사용자 정보 새로고침
    if (result == true) {
      _loadUserData();
    }
  }

  /// 상품 파일 업로드 페이지로 이동
  void _navigateToProductFileUpload() async {
    await CustomNavigationUtil.to(
      context,
      const ProductFileUploadView(),
    );
  }

  /// 로그아웃 처리
  /// GetStorage에서 사용자 정보와 인증 정보를 삭제하고 로그인 화면으로 이동
  void _handleLogout() {
    // scaffoldContext 저장 (다이얼로그 닫은 후 사용하기 위해)
    final scaffoldContext = context;
    
    // 로그아웃 확인 다이얼로그 표시
    CustomDialog.show(
      context,
      title: '로그아웃',
      message: '정말 로그아웃 하시겠습니까?',
      type: DialogType.dual,
      confirmText: '로그아웃',
      cancelText: '취소',
      autoDismissOnConfirm: false,
      onConfirm: () async {
        // 다이얼로그 닫기
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        
        try {
          final storage = GetStorage();
          
          // GetStorage에서 사용자 정보 삭제
          storage.remove('user');
          storage.remove('user_auth_identity');
          
          // 성공 메시지 표시
          if (scaffoldContext.mounted) {
            CustomSnackBar.showSuccess(
              scaffoldContext,
              message: '로그아웃 되었습니다.',
            );
            
            // 로그인 화면으로 이동 (모든 화면 스택 제거)
            CustomNavigationUtil.offAll(scaffoldContext, const LoginView());
          }
        } catch (e) {
          // 로그아웃 실패 시에도 로그인 화면으로 이동
          if (scaffoldContext.mounted) {
            CustomSnackBar.showError(
              scaffoldContext,
              message: '로그아웃 중 오류가 발생했습니다.',
            );
            CustomNavigationUtil.offAll(scaffoldContext, const LoginView());
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Scaffold(
          backgroundColor: p.background,
          appBar: CustomAppBar(
            title: '홈',
            centerTitle: true,
            titleTextStyle: config.boldLabelStyle,
            backgroundColor: p.background,
            foregroundColor: p.textPrimary,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentUser == null
                  ? Center(
                      child: CustomColumn(
                        spacing: 16,
                        children: [
                          const Icon(Icons.person_off, size: 64, color: Colors.grey),
                          CustomText(
                            '사용자 정보를 불러올 수 없습니다.',
                            fontSize: 16,
                            textAlign: TextAlign.center,
                          ),
                          CustomButton(
                            btnText: '다시 시도',
                            buttonType: ButtonType.outlined,
                            onCallBack: _loadUserData,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: CustomPadding(
                        padding: config.screenPadding,
                        child: CustomColumn(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: config.largeSpacing,
                          children: [
                            // 사용자 정보 카드
                            CustomCard(
                              padding: const EdgeInsets.all(20),
                              child: CustomColumn(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 12,
                                children: [
                                  // 사용자 정보 제목
                                  CustomText(
                                    '사용자 정보',
                                    style: config.titleStyle,
                                    textAlign: TextAlign.left,
                                  ),
                                  const Divider(),
                                  
                                  // 이름
                                  _buildInfoRow(
                                    icon: Icons.person,
                                    label: '이름',
                                    value: _currentUser!.uName,
                                  ),
                                  
                                  // 이메일
                                  _buildInfoRow(
                                    icon: Icons.email,
                                    label: '이메일',
                                    value: _currentUser!.uEmail,
                                  ),
                                  
                                  // 전화번호
                                  if (_currentUser!.uPhone != null && _currentUser!.uPhone!.isNotEmpty)
                                    _buildInfoRow(
                                      icon: Icons.phone,
                                      label: '전화번호',
                                      value: _currentUser!.uPhone!,
                                    ),
                                  
                                  // 주소
                                  if (_currentUser!.uAddress != null && _currentUser!.uAddress!.isNotEmpty)
                                    _buildInfoRow(
                                      icon: Icons.home,
                                      label: '주소',
                                      value: _currentUser!.uAddress!,
                                    ),
                                ],
                              ),
                            ),
                            
                            // 프로필 수정 버튼
                            CustomButton(
                              btnText: '개인정보 수정',
                              buttonType: ButtonType.elevated,
                              onCallBack: _navigateToProfileEdit,
                              minimumSize: Size(double.infinity, config.defaultButtonHeight),
                            ),
                            
                            // 상품 파일 업로드 버튼
                            CustomButton(
                              btnText: '파일 업로드',
                              buttonType: ButtonType.outlined,
                              onCallBack: _navigateToProductFileUpload,
                              minimumSize: Size(double.infinity, config.defaultButtonHeight),
                            ),
                            
                            // 로그아웃 버튼
                            CustomButton(
                              btnText: '로그아웃',
                              buttonType: ButtonType.outlined,
                              onCallBack: _handleLogout,
                              minimumSize: Size(double.infinity, config.defaultButtonHeight),
                            ),
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }

  /// 정보 행 위젯 생성
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: CustomColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              CustomText(
                label,
                fontSize: 12,
                fontWeight: FontWeight.normal,
                textAlign: TextAlign.left,
              ),
              CustomText(
                value,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }

  //--------Functions ------------
  
  //------------------------------
}