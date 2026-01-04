import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/model/user_auth_identity.dart';
import 'package:shoes_shop_app/view/main/auth/signup_view.dart';
import 'package:shoes_shop_app/view/main/auth/user_auth_ui_config.dart';
import 'package:shoes_shop_app/view/home.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/utils/admin_tablet_utils.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_login_view.dart';
import 'package:shoes_shop_app/view/main/Admin/auth/admin_login_view_dev.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_mobile_block_view.dart';
import 'package:shoes_shop_app/view/user/product/list_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>(debugLabel: 'LoginForm');

  /// 아이디 입력 컨트롤러
  final TextEditingController _idController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  /// 구글 로그인 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// 로고 표시 여부 (기본값: false, 2초 안에 5번 클릭하면 true로 변경)
  final bool _showLogo = false;

  /// 관리자 진입을 위한 로고 탭 횟수
  int _adminTapCount = 0;
  
  /// 관리자 진입을 위한 타이머 (2초)
  Timer? _adminTapTimer;

  @override
  void initState() {
    super.initState();
    // API base URL 설정 (Android 에뮬레이터 지원)
    CustomNetworkUtil.setBaseUrl(config.getApiBaseUrl());
    
    // 로그인 화면 진입 시 기존 사용자 정보 삭제 (새로운 로그인을 위함)
    _clearStoredUserData();
    
  }
  
  /// GetStorage에서 사용자 정보 삭제
  void _clearStoredUserData() {
    try {
      final storage = GetStorage();
      storage.remove('user');
      storage.remove('user_auth_identity');
    } catch (e) {
      // 기존 사용자 정보 삭제 중 오류 무시
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _adminTapTimer?.cancel();
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
              title: const Text('로그인'),
              centerTitle: userAuthAppBarCenterTitle,
              titleTextStyle: userAuthAppBarTitleStyle.copyWith(color: p.textPrimary),
              backgroundColor: p.background,
              foregroundColor: p.textPrimary,
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: userAuthFormHorizontalPadding,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: userAuthDefaultSpacing),
                        // 로고 영역 (회색 박스 또는 로고 이미지)
                        GestureDetector(
                          onTap: _handleLogoAreaTap,
                          child: Container(
                            height: userAuthLogoHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: p.divider,
                              borderRadius: userAuthDefaultBorderRadius,
                            ),
                            child: _showLogo
                                ? Image.asset(
                                    'images/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Text(
                                          'SHOE KING',
                                          style: userAuthLargeTitleStyle,
                                        ),
                                      );
                                    },
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(height: userAuthDefaultSpacing),
                        TextFormField(
                          controller: _idController,
                          decoration: InputDecoration(
                            labelText: '이메일',
                            hintText: '이메일을 입력하세요',
                            prefixIcon: const Icon(Icons.email),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '이메일을 입력해주세요';
                            }
                            if (!CustomCommonUtil.isEmail(value.trim())) {
                              return '올바른 이메일 형식이 아닙니다';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: userAuthDefaultSpacing),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: '비밀번호',
                            hintText: '비밀번호를 입력하세요',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '비밀번호를 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: userAuthLargeSpacing),
                        Center(
                          child: SizedBox(
                            width: userAuthButtonMaxWidth,
                            height: userAuthButtonHeight,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: p.primary,
                                foregroundColor: p.textOnPrimary,
                              ),
                              child: const Text(
                                '로그인',
                                style: userAuthButtonTextStyle,
                              ),
                            ),
                          ),
                        ),
                        userAuthButtonSpacing,
                        Center(
                          child: SizedBox(
                            width: userAuthButtonMaxWidth,
                            height: userAuthButtonHeight,
                            child: OutlinedButton(
                              onPressed: _navigateToSignUp,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: p.divider),
                                foregroundColor: p.textPrimary,
                              ),
                              child: const Text(
                                '회원가입',
                                style: userAuthButtonTextStyle,
                              ),
                            ),
                          ),
                        ),
                        userAuthButtonSpacing,
                        // 구글 소셜 로그인 버튼
                        Center(
                          child: SizedBox(
                            width: userAuthButtonMaxWidth,
                            height: userAuthButtonHeight,
                            child: OutlinedButton.icon(
                              onPressed: _handleGoogleSignIn,
                              icon: Image.network(
                                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                height: userAuthGoogleIconSize,
                                width: userAuthGoogleIconSize,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.login, size: userAuthGoogleIconSize);
                                },
                              ),
                              label: const Text('구글로 로그인'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: p.cardBackground,
                                foregroundColor: p.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        userAuthButtonSpacing,
                        Center(
                          child: SizedBox(
                            width: userAuthButtonMaxWidth,
                            height: userAuthButtonHeight,
                            child: OutlinedButton(
                              onPressed: _navigateToTestPage,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: p.divider),
                                foregroundColor: p.textPrimary,
                              ),
                              child: const Text(
                                '회원가입(폼완성)',
                                style: userAuthButtonTextStyle,
                              ),
                            ),
                          ),
                        ),
                        userAuthButtonSpacing,
                        Center(
                          child: SizedBox(
                            width: userAuthButtonMaxWidth,
                            height: userAuthButtonHeight,
                            child: OutlinedButton(
                              onPressed: _handleHongGildongLogin,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: p.divider),
                                foregroundColor: p.textPrimary,
                              ),
                              child: const Text(
                                '홍길동 로그인',
                                style: userAuthButtonTextStyle,
                              ),
                            ),
                          ),
                        ),
                        userAuthButtonSpacing,
                        Center(
                          child: SizedBox(
                            width: userAuthButtonMaxWidth,
                            height: userAuthButtonHeight,
                            child: OutlinedButton(
                              onPressed: _navigateToAdminLogin,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: p.divider),
                                foregroundColor: p.textPrimary,
                              ),
                              child: const Text(
                                '관리자 로그인',
                                style: userAuthButtonTextStyle,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: userAuthDefaultSpacing),
                      ],
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

  /// 로고 탭 처리
  /// 2초 안에 5번 탭하면 관리자 진입 모드 활성화
  void _handleLogoAreaTap() {
    _adminTapTimer?.cancel();

    setState(() {
      _adminTapCount++;
    });

    if (_adminTapCount >= 5) {
      _adminTapCount = 0;
      _adminTapTimer?.cancel();

      final isTabletDevice = isTablet(context);
      
      if (isTabletDevice) {
        Get.to(() => AdminLoginView());
      } else {
        Get.to(() => AdminMobileBlockView());
      }
      return;
    }

    _adminTapTimer = Timer(const Duration(seconds: 2), () {
      _adminTapTimer?.cancel();
      if (mounted) {
        setState(() {
          _adminTapCount = 0;
        });
      }
    });
  }

  /// 로그인 성공 후 처리
  void _handleLoginSuccess(User user, {UserAuthIdentity? authIdentity}) {
    // GetStorage에 사용자 정보 저장
    _saveUserToStorage(user, authIdentity);
    
    CustomCommonUtil.showSuccessSnackbar(
      context: context,
      title: '로그인 성공',
      message: '${user.uName}님 환영합니다!',
    );
    // 로그인 성공 후 홈 화면으로 이동 (이전 스택 모두 제거)
    // Get.offAll(() => Home());
    Get.offAll(() => ProductListView());
  }
  
  /// GetStorage에 사용자 정보 저장
  void _saveUserToStorage(User user, UserAuthIdentity? authIdentity) {
    try {
      final storage = GetStorage();
      // User 정보 저장
      storage.write('user', jsonEncode(user.toJson()));
      // UserAuthIdentity 정보 저장 (소셜 로그인 여부 확인용)
      if (authIdentity != null) {
        storage.write('user_auth_identity', jsonEncode(authIdentity.toJson()));
      }
    } catch (e) {
      // TODO: AppLogger 임시로 막음
      // AppLogger.e('사용자 정보 저장 실패', tag: 'Login', error: e);
    }
  }

  /// 로그인 차단 처리 (로딩 오버레이를 닫고 다이얼로그 표시)
  /// [dialogShownCallback]은 다이얼로그가 표시되었음을 알리기 위한 콜백
  Future<void> _blockLogin(String message, VoidCallback dialogShownCallback) async {
    if (mounted) {
      // 로딩 오버레이를 먼저 닫기
      CustomCommonUtil.hideLoadingOverlay(context);
      // Navigator 스택이 정리될 시간을 주기 위해 약간의 딜레이
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        // showConfirmDialog를 await하지 않음 (다이얼로그가 닫힐 때까지 기다리지 않음)
        // 다이얼로그만 표시하고 즉시 return하여 로그인 프로세스를 중단
        CustomCommonUtil.showConfirmDialog(
          context: context,
          title: '로그인 불가',
          message: message,
          confirmText: '확인',
          onConfirm: () {
            // 확인 버튼을 눌러도 아무것도 하지 않음 (다이얼로그만 닫힘)
          },
        );
        dialogShownCallback(); // 다이얼로그 표시됨을 알림
      }
    }
  }

  /// 탈퇴 회원 체크
  /// user.u_quit_date가 null이 아니면 탈퇴 회원
  bool _checkQuitUser(User user) {
    return user.uQuitDate != null && user.uQuitDate!.isNotEmpty;
  }

  /// 6개월 미접속 체크 (휴면 회원 처리)
  /// user_auth_identities.last_login_at을 기준으로 체크
  /// 반환값: true면 휴면 처리되어 로그인 차단, false면 정상 진행
  Future<bool> _checkDormantAccount(UserAuthIdentity authIdentity) async {
    try {
      if (authIdentity.lastLoginAt == null || authIdentity.lastLoginAt!.isEmpty) {
        // 마지막 로그인 기록이 없으면 정상 진행 (신규 회원일 수 있음)
        return false;
      }
      
      // ISO 8601 형식으로 통일되었으므로 직접 파싱 가능
      final lastLoginDateTime = DateTime.parse(authIdentity.lastLoginAt!);
      final now = DateTime.now();
      final daysDifference = now.difference(lastLoginDateTime).inDays;
      
      // config.dormantAccountDays일 이상 미접속 시 휴면 회원 처리
      if (daysDifference >= config.dormantAccountDays) {
        // _checkDormantAccount는 외부에서 호출되므로 loadingOverlayClosed를 전달할 수 없음
        // 이 경우는 finally 블록에서 처리하므로 여기서는 닫지 않음
        return true;
      }
      return false;
    } catch (e) {
      return false; // 에러 발생 시 로그인 진행
    }
  }

  /// 로그인 시간 업데이트
  /// user_auth_identities 테이블의 last_login_at 필드를 업데이트
  Future<void> _updateLoginTime(int authSeq) async {
    try {
      await CustomNetworkUtil.post<Map<String, dynamic>>(
        '/api/user_auth_identities/$authSeq/update_login_time',
      );
      // 로그인 시간 업데이트 (실패해도 무시)
    } catch (e) {
      // 로그인 시간 업데이트 중 오류 무시
    }
  }


  /// 로그인 버튼 클릭 처리
  void _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final input = _idController.text.trim();
    final password = _passwordController.text.trim();
    final isEmail = CustomCommonUtil.isEmail(input);

    // 로딩 오버레이 표시 (통신 중 다른 버튼 클릭 방지)
    CustomCommonUtil.showLoadingOverlay(context, message: '로그인 중...');
    
    // 다이얼로그가 표시되었는지 추적 (finally 블록에서 로딩 오버레이를 닫지 않도록)
    bool dialogShown = false;

    try {
      // 1. user_auth_identities 테이블에서 provider='local'로 조회
      final authResponse = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/user_auth_identities/provider/local',
        fromJson: (json) => json,
      );

      if (!authResponse.success || authResponse.data == null) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '로그인 중 오류가 발생했습니다: ${authResponse.error}',
        );
        return;
      }

      // 2. 이메일 형식 검증 (이중 체크)
      if (!isEmail) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '올바른 이메일 형식을 입력해주세요',
        );
        return;
      }

      // 3. provider_subject가 입력한 이메일과 일치하는 인증 정보 찾기
      final List<dynamic> authList = authResponse.data!['results'] ?? [];
      Map<String, dynamic>? foundAuth;
      
      for (var auth in authList) {
        if (auth['provider_subject'] == input) {
          foundAuth = auth as Map<String, dynamic>;
          break;
        }
      }

      if (foundAuth == null) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '이메일 또는 비밀번호가 올바르지 않습니다.',
        );
        return;
      }

      // 4. 비밀번호 검증 (평문 비교 - 임시, 보안상 백엔드에서 해시 비교해야 함)
      if (foundAuth['password'] != password) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '이메일 또는 비밀번호가 올바르지 않습니다.',
        );
        return;
      }

      // 5. user 테이블에서 사용자 정보 조회
      final int uSeq = foundAuth['u_seq'] as int;
      
      final userResponse = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/users/$uSeq',
        fromJson: (json) => json,
      );

      if (!userResponse.success || userResponse.data == null) {
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '사용자 정보를 불러올 수 없습니다: ${userResponse.error}',
        );
        return;
      }

      final userData = userResponse.data!['result'] as Map<String, dynamic>;
      final user = User(
        uSeq: userData['u_seq'] as int?,
        uEmail: userData['u_email'] as String,
        uName: userData['u_name'] as String,
        uPhone: userData['u_phone'] as String?,
        uAddress: userData['u_address'] as String?,
        createdAt: userData['created_at'] as String?,
        uQuitDate: userData['u_quit_date'] as String?,
      );

      // 6. 탈퇴 회원 체크
      if (_checkQuitUser(user)) {
        await _blockLogin('탈퇴한 회원입니다.', () => dialogShown = true);
        return; // 로그인 프로세스 중단 (홈 화면으로 이동하지 않음)
      }

      // 7. UserAuthIdentity 객체 생성
      final authIdentity = UserAuthIdentity(
        authSeq: foundAuth['auth_seq'] as int?,
        uSeq: uSeq,
        provider: foundAuth['provider'] as String,
        providerSubject: foundAuth['provider_subject'] as String,
        providerIssuer: foundAuth['provider_issuer'] as String?,
        emailAtProvider: foundAuth['email_at_provider'] as String?,
        password: foundAuth['password'] as String?,
        createdAt: foundAuth['created_at'] as String?,
        lastLoginAt: foundAuth['last_login_at'] as String?,
      );

      // 8. 휴면 회원 체크 (6개월 미접속)
      final isDormant = await _checkDormantAccount(authIdentity);
      if (isDormant) {
        await _blockLogin('장기간 미접속으로 휴면 회원 처리 되었습니다.', () => dialogShown = true);
        return;
      }

      // 9. 로그인 시간 업데이트
      if (authIdentity.authSeq != null) {
        await _updateLoginTime(authIdentity.authSeq!);
      }

      // 10. 로그인 성공 처리
      _handleLoginSuccess(user, authIdentity: authIdentity);
    } catch (error) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '로그인 중 오류가 발생했습니다: $error',
      );
    } finally {
      // 로딩 오버레이 숨기기 (다이얼로그가 표시되지 않은 경우에만)
      // 다이얼로그가 표시된 경우는 _blockLogin에서 이미 닫았으므로 중복 닫기 방지
      if (mounted && !dialogShown) {
        try {
          CustomCommonUtil.hideLoadingOverlay(context);
        } catch (e) {
          // 이미 닫혔을 수 있으므로 무시
        }
      }
    }
  }


  /// 회원가입 화면으로 이동
  void _navigateToSignUp() {
    Get.to(() => SignUpView());
  }

  /// 테스트 페이지로 이동 (회원가입 페이지에 더미 데이터 전달)
  void _navigateToTestPage() {
    // 더미 데이터 준비 (모든 필드 채우기 + 약관 동의 체크)
    final testData = {
      'email': 'test@example.com',
      'password': 'qwer1234', // 통일된 테스트 비밀번호
      'name': '테스트 사용자',
      'phone': '010-1234-5678',
      'autoAgree': 'true', // 약관 동의 자동 체크
    };
    
    // 회원가입 페이지로 이동 (더미 데이터 전달)
    Get.to(() => SignUpView(testData: testData));
  }

  /// 홍길동 계정으로 자동 로그인
  void _handleHongGildongLogin() {
    // 입력 필드에 자동으로 값 채우기
    _idController.text = 'user001@example.com';
    _passwordController.text = 'qwer1234';
    
    // 자동 로그인 실행
    _handleLogin();
  }

  /// 관리자 로그인 화면으로 이동
  void _navigateToAdminLogin() {
    final isTabletDevice = isTablet(context);
    
    if (isTabletDevice) {
      Get.to(() => AdminLoginViewDev());
    } else {
      Get.to(() => AdminMobileBlockView());
    }
  }

  /// 구글 소셜 로그인 처리
  Future<void> _handleGoogleSignIn() async {
    // 다이얼로그가 표시되었는지 추적 (finally 블록에서 로딩 오버레이를 닫지 않도록)
    bool dialogShown = false;
    
    try {
      // 구글 로그인 시도
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 사용자가 로그인을 취소한 경우 - 취소 시 아무것도 하지 않고 로그인 화면에 머무름
        return;
      }

      // 로딩 오버레이 표시 (통신 중 다른 버튼 클릭 방지)
      CustomCommonUtil.showLoadingOverlay(context, message: '구글 로그인 중...');
      
      // 1. 백엔드 API에 소셜 로그인 요청 (Form 데이터)
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${config.getApiBaseUrl()}/api/auth/social/login'),
      );
      
      request.fields['provider'] = 'google';
      request.fields['provider_subject'] = googleUser.id;
      request.fields['email'] = googleUser.email;
      request.fields['name'] = googleUser.displayName ?? '구글 사용자';
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        final errorMsg = errorBody['errorMsg'] ?? '소셜 로그인 실패';
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '소셜 로그인 실패: $errorMsg',
        );
        return;
      }
      
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (responseData['result'] == 'Error') {
        final errorMsg = responseData['errorMsg'] ?? '소셜 로그인 실패';
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '소셜 로그인 실패: $errorMsg',
        );
        return;
      }
      
      final result = responseData['result'] as Map<String, dynamic>;
      
      // 2. User 객체 생성
      final user = User(
        uSeq: result['u_seq'] as int?,
        uEmail: result['u_email'] as String,
        uName: result['u_name'] as String,
        uPhone: result['u_phone'] as String?,
        uAddress: result['u_address'] as String?,
        createdAt: result['created_at'] as String?,
        uQuitDate: result['u_quit_date'] as String?,
      );
      
      // 3. UserAuthIdentity 객체 생성
      final authIdentity = UserAuthIdentity(
        authSeq: result['auth_seq'] as int?,
        uSeq: result['u_seq'] as int,
        provider: result['provider'] as String,
        providerSubject: result['provider_subject'] as String,
        providerIssuer: null,
        emailAtProvider: result['u_email'] as String?,
        password: null,
        createdAt: result['created_at'] as String?,
        lastLoginAt: result['last_login_at'] as String?,
      );
      
      // 4. 탈퇴 회원 체크
      if (_checkQuitUser(user)) {
        await _blockLogin('탈퇴한 회원입니다.', () => dialogShown = true);
        return;
      }
      
      // 5. 휴면 회원 체크 (6개월 미접속)
      final isDormant = await _checkDormantAccount(authIdentity);
      if (isDormant) {
        await _blockLogin('장기간 미접속으로 휴면 회원 처리 되었습니다.', () => dialogShown = true);
        return;
      }
      
      // 6. 로그인 시간 업데이트
      if (authIdentity.authSeq != null) {
        await _updateLoginTime(authIdentity.authSeq!);
      }
      
      // 7. 로그인 성공 처리
      _handleLoginSuccess(user, authIdentity: authIdentity);
      
    } catch (error) {
      // 에러 메시지 간소화 (너무 긴 에러 메시지 방지)
      String errorMessage = '구글 로그인 중 오류가 발생했습니다.';
      
      // 특정 에러 타입에 대한 안내 메시지
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('configuration') || errorString.contains('client_id')) {
        errorMessage = '구글 로그인 설정이 올바르지 않습니다.\n실제 기기에서 테스트해주세요.';
      } else if (errorString.contains('network') || errorString.contains('connection')) {
        errorMessage = '네트워크 연결을 확인해주세요.';
      }
      
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: errorMessage,
      );
    } finally {
      // 로딩 오버레이 숨기기 (다이얼로그가 표시되지 않은 경우에만)
      // 다이얼로그가 표시된 경우는 _blockLogin에서 이미 닫았으므로 중복 닫기 방지
      if (mounted && !dialogShown) {
        try {
          CustomCommonUtil.hideLoadingOverlay(context);
        } catch (e) {
          // 이미 닫혔을 수 있으므로 무시
        }
      }
    }
  }
}

// ============================================
// 변경 이력
// ============================================
// 2025-12-31: 김택권
//   - 로그인 화면 생성
//   - 이메일/비밀번호 로그인 기능
//   - 구글 소셜 로그인 기능
//   - 관리자 진입 기능 (로고 영역 5번 탭)
//   - 탈퇴 회원 체크
//   - 휴면 회원 체크 (6개월 미접속)
//   - 로그인 시간 업데이트
//   - GetStorage를 사용한 사용자 정보 저장/삭제

// 2026-01-02: 김택권
//   - 디버그 메시지 정리 (과도한 로그 제거)
