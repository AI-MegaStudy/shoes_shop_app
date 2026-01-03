import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/utils/admin_tablet_utils.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:shoes_shop_app/model/staff.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_mobile_block_view.dart';
import 'package:shoes_shop_app/view/main/Admin/product/product_management.dart';
import 'package:shoes_shop_app/view/main/main_ui_config.dart';
import 'package:shoes_shop_app/view/main/auth/login_view.dart';
import 'package:shoes_shop_app/theme/app_colors.dart';

/// 관리자 로그인 화면 (개발용)
/// 태블릿에서 가로 모드로 강제 표시되는 관리자 전용 로그인 화면입니다.
/// MySQL staff 테이블의 s_id를 사용하여 로그인합니다.

class AdminLoginViewDev extends StatefulWidget {
  const AdminLoginViewDev({super.key});

  @override
  State<AdminLoginViewDev> createState() => _AdminLoginViewDevState();
}

class _AdminLoginViewDevState extends State<AdminLoginViewDev> {
  /// Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>(debugLabel: 'AdminLoginForm');

  /// 직원 ID 입력 컨트롤러
  final TextEditingController _sIdController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// 태블릿이 아니면 모바일 차단 화면으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isTablet(context)) {
        Get.to(() => AdminMobileBlockView());
      } else {
        lockTabletLandscape(context);
      }
    });
  }

  @override
  void dispose() {
    _sIdController.dispose();
    _passwordController.dispose();
    unlockAllOrientations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Builder(
        builder: (context) {
          final p = context.palette;
          return Scaffold(
            backgroundColor: p.background,
            appBar: AppBar(
              title: const Text('관리자 로그인'),
              centerTitle: mainAppBarCenterTitle,
              titleTextStyle: mainAppBarTitleStyle.copyWith(color: p.textPrimary),
              backgroundColor: p.background,
              foregroundColor: p.textPrimary,
              toolbarHeight: 48,
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: config.dialogMaxWidth),
                    child: Padding(
                      padding: mainDefaultPadding,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '관리자 로그인',
                              style: mainLargeTitleStyle.copyWith(color: p.textPrimary),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: mainLargeSpacing),

                            Text(
                              '태블릿에서만 접근 가능합니다',
                              style: mainBodyTextStyle.copyWith(
                                color: p.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: mainLargeSpacing),

                            TextFormField(
                              controller: _sIdController,
                              decoration: InputDecoration(
                                labelText: '직원 ID',
                                hintText: '직원 ID를 입력하세요',
                                prefixIcon: Icon(Icons.person, color: p.textSecondary),
                                border: const OutlineInputBorder(),
                              ),
                              style: TextStyle(color: p.textPrimary),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '직원 ID를 입력해주세요';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: mainLargeSpacing),

                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: '비밀번호',
                                hintText: '비밀번호를 입력하세요',
                                prefixIcon: Icon(Icons.lock, color: p.textSecondary),
                                border: const OutlineInputBorder(),
                              ),
                              style: TextStyle(color: p.textPrimary),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '비밀번호를 입력해주세요';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: mainLargeSpacing),

                            Center(
                              child: SizedBox(
                                width: mainButtonMaxWidth,
                                height: mainButtonHeight,
                                child: ElevatedButton(
                                  onPressed: _handleLogin,
                                  style: mainPrimaryButtonStyle.copyWith(
                                    backgroundColor: WidgetStateProperty.all(p.primary),
                                    foregroundColor: WidgetStateProperty.all(p.textOnPrimary),
                                  ),
                                  child: const Text(
                                    '로그인',
                                    style: mainMediumTitleStyle,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: mainDefaultSpacing),

                            Center(
                              child: SizedBox(
                                width: mainButtonMaxWidth,
                                height: mainButtonHeight,
                                child: OutlinedButton(
                                  onPressed: _handleAutoLogin,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: p.divider),
                                    foregroundColor: p.textPrimary,
                                  ),
                                  child: const Text(
                                    '자동 로그인 (staff004)',
                                    style: mainMediumTitleStyle,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: mainDefaultSpacing),

                            Center(
                              child: SizedBox(
                                width: mainButtonMaxWidth,
                                height: mainButtonHeight,
                                child: OutlinedButton(
                                  onPressed: _navigateToUserLogin,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: p.divider),
                                    foregroundColor: p.textPrimary,
                                  ),
                                  child: const Text(
                                    '사용자 로그인',
                                    style: mainMediumTitleStyle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 키보드 내리기
  void _unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// 사용자 로그인 페이지로 이동
  void _navigateToUserLogin() {
    Get.offAll(() => LoginView());
  }

  /// 자동 로그인 (staff004)
  void _handleAutoLogin() {
    _sIdController.text = 'staff004';
    _passwordController.text = 'pass1234';
    _handleLogin();
  }

  /// 로그인 버튼 클릭 처리
  void _handleLogin() async {
    _unfocusKeyboard();

    if (!_formKey.currentState!.validate()) return;

    final sId = _sIdController.text.trim();
    final password = _passwordController.text.trim();

    print('[AdminLogin] 로그인 시도 시작');
    print('[AdminLogin] 입력된 s_id: $sId');
    print('[AdminLogin] 입력된 password 길이: ${password.length}');

    try {
      // API base URL 설정
      final apiBaseUrl = config.getApiBaseUrl();
      CustomNetworkUtil.setBaseUrl(apiBaseUrl);
      print('[AdminLogin] API Base URL: $apiBaseUrl');

      // s_id로 staff 조회
      final requestUrl = '/api/staff/by_id/$sId';
      print('[AdminLogin] 요청 URL: $requestUrl');
      
      final response = await CustomNetworkUtil.get<Map<String, dynamic>>(
        requestUrl,
        fromJson: (json) => json,
      );

      print('[AdminLogin] API 응답 수신');
      print('[AdminLogin] response.success: ${response.success}');
      print('[AdminLogin] response.statusCode: ${response.statusCode}');
      print('[AdminLogin] response.error: ${response.error}');
      print('[AdminLogin] response.rawBody: ${response.rawBody}');

      if (!response.success || response.data == null) {
        print('[AdminLogin] 로그인 실패: API 응답 실패');
        print('[AdminLogin] 실패 원인: success=${response.success}, data=${response.data == null ? "null" : "not null"}');
        if (response.error != null) {
          print('[AdminLogin] 에러 메시지: ${response.error}');
        }
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          title: '로그인 실패',
          message: '직원 ID 또는 비밀번호가 올바르지 않습니다.',
        );
        return;
      }

      final result = response.data!['result'] as Map<String, dynamic>?;
      print('[AdminLogin] result 파싱 결과: ${result == null ? "null" : "not null"}');
      
      if (result == null) {
        print('[AdminLogin] 로그인 실패: result가 null');
        print('[AdminLogin] response.data 내용: ${response.data}');
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          title: '로그인 실패',
          message: '직원 ID 또는 비밀번호가 올바르지 않습니다.',
        );
        return;
      }

      print('[AdminLogin] 직원 정보 조회 성공');
      print('[AdminLogin] s_seq: ${result['s_seq']}');
      print('[AdminLogin] s_id: ${result['s_id']}');
      print('[AdminLogin] s_name: ${result['s_name']}');

      // 비밀번호 검증
      final staffPassword = result['s_password'] as String?;
      print('[AdminLogin] 비밀번호 검증 시작');
      print('[AdminLogin] 저장된 비밀번호 존재 여부: ${staffPassword != null}');
      print('[AdminLogin] 저장된 비밀번호 길이: ${staffPassword?.length ?? 0}');
      print('[AdminLogin] 입력된 비밀번호 길이: ${password.length}');
      
      if (staffPassword == null || staffPassword != password) {
        print('[AdminLogin] 로그인 실패: 비밀번호 불일치');
        print('[AdminLogin] 저장된 비밀번호: ${staffPassword ?? "null"}');
        print('[AdminLogin] 입력된 비밀번호: $password');
        print('[AdminLogin] 비밀번호 일치 여부: ${staffPassword == password}');
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          title: '로그인 실패',
          message: '직원 ID 또는 비밀번호가 올바르지 않습니다.',
        );
        return;
      }

      print('[AdminLogin] 비밀번호 검증 성공');

      // Staff 객체 생성
      final staff = Staff.fromJson(result);
      print('[AdminLogin] Staff 객체 생성 완료: ${staff.s_name}');

      // GetStorage에 관리자 정보 저장
      final storage = GetStorage();
      storage.write('admin', jsonEncode(staff.toJson()));
      print('[AdminLogin] 관리자 정보 저장 완료');

      // 로그인 성공
      CustomCommonUtil.showSuccessSnackbar(
        context: context,
        title: '로그인 성공',
        message: '${staff.s_name}님 환영합니다!',
      );

      print('[AdminLogin] 로그인 성공 - 관리자 메인 화면으로 이동');
      // 관리자 메인 화면으로 이동
      Get.to(() => ProductManagement());
    } catch (error, stackTrace) {
      print('[AdminLogin] 로그인 중 예외 발생');
      print('[AdminLogin] 예외 타입: ${error.runtimeType}');
      print('[AdminLogin] 예외 메시지: $error');
      print('[AdminLogin] 스택 트레이스: $stackTrace');
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '로그인 중 오류가 발생했습니다.',
      );
    }
  }
}

