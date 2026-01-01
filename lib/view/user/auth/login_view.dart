import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/custom/external_util/network/custom_network_util.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/model/user_auth_identity.dart';
import 'package:shoes_shop_app/view/user/auth/signup_view.dart';
import 'package:shoes_shop_app/view/home.dart' as home;
import 'package:shoes_shop_app/utils/custom_common_util.dart';
import 'package:shoes_shop_app/utils/admin_tablet_utils.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_login_view.dart';
import 'package:shoes_shop_app/view/admin/auth/admin_mobile_block_view.dart';

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
      if (kDebugMode) {
        print('🔵 [Login] 기존 사용자 정보 삭제 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [Login] 기존 사용자 정보 삭제 중 오류: $e');
      }
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
              centerTitle: true,
              titleTextStyle: config.boldLabelStyle.copyWith(color: p.textPrimary),
              backgroundColor: p.background,
              foregroundColor: p.textPrimary,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: config.formHorizontalPadding,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: config.defaultSpacing),
                        // 로고 영역 (회색 박스 또는 로고 이미지)
                        GestureDetector(
                          onTap: _handleLogoAreaTap,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _showLogo
                                ? Image.asset(
                                    'images/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Text(
                                          'SHOE KING',
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(height: config.defaultSpacing),
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
                        SizedBox(height: config.defaultSpacing),
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
                        config.largeVerticalSpacing,
                        SizedBox(
                          width: double.infinity,
                          height: config.defaultButtonHeight,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            child: const Text(
                              '로그인',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        config.defaultVerticalSpacing,
                        SizedBox(
                          width: double.infinity,
                          height: config.defaultButtonHeight,
                          child: OutlinedButton(
                            onPressed: _navigateToSignUp,
                            child: const Text(
                              '회원가입',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 구글 소셜 로그인 버튼
                        SizedBox(
                          width: double.infinity,
                          height: config.defaultButtonHeight,
                          child: OutlinedButton.icon(
                            onPressed: _handleGoogleSignIn,
                            icon: Image.network(
                              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                              height: 20,
                              width: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.login, size: 20);
                              },
                            ),
                            label: const Text('구글로 로그인'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: config.defaultButtonHeight,
                          child: OutlinedButton(
                            onPressed: _navigateToTestPage,
                            child: const Text(
                              '테스트 페이지로 이동',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: config.defaultSpacing),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginView()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminMobileBlockView()),
        );
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
    // 로그인 성공 후 홈 화면으로 이동
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const home.Home()),
      (route) => false,
    );
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
        if (kDebugMode) {
          print('🔵 [Login] 마지막 로그인 기록 없음 - 신규 회원으로 간주');
        }
        return false;
      }
      
      // ISO 8601 형식으로 통일되었으므로 직접 파싱 가능
      final lastLoginDateTime = DateTime.parse(authIdentity.lastLoginAt!);
      final now = DateTime.now();
      final daysDifference = now.difference(lastLoginDateTime).inDays;
      
      if (kDebugMode) {
        print('🔵 [Login] 마지막 로그인: $lastLoginDateTime, 현재: $now, 차이: $daysDifference일');
      }
      
      // config.dormantAccountDays일 이상 미접속 시 휴면 회원 처리
      if (daysDifference >= config.dormantAccountDays) {
        if (kDebugMode) {
          print('⚠️ [Login] ${config.dormantAccountDays}일 이상 미접속 - 휴면 회원 처리, User u_seq: ${authIdentity.uSeq}');
        }
        // _checkDormantAccount는 외부에서 호출되므로 loadingOverlayClosed를 전달할 수 없음
        // 이 경우는 finally 블록에서 처리하므로 여기서는 닫지 않음
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════');
        print('🚨 [ERROR] 함수: _checkDormantAccount');
        print('❌ 오류: $e');
        print('📚 스택 트레이스: $stackTrace');
        print('═══════════════════════════════════════════════════════');
      }
      return false; // 에러 발생 시 로그인 진행
    }
  }

  /// 로그인 시간 업데이트
  /// user_auth_identities 테이블의 last_login_at 필드를 업데이트
  Future<void> _updateLoginTime(int authSeq) async {
    try {
      if (kDebugMode) {
        print('🔵 [Login] 로그인 시간 업데이트 API 호출: auth_seq=$authSeq');
      }
      
      final response = await CustomNetworkUtil.post<Map<String, dynamic>>(
        '/api/user_auth_identities/$authSeq/update_login_time',
      );
      
      if (kDebugMode) {
        print('🔵 [Login] 로그인 시간 업데이트 응답: success=${response.success}, error=${response.error}');
      }
      
      if (!response.success) {
        if (kDebugMode) {
          print('⚠️ [Login] 로그인 시간 업데이트 실패: ${response.error}');
        }
      } else {
        if (kDebugMode) {
          print('✅ [Login] 로그인 시간 업데이트 성공');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════');
        print('🚨 [ERROR] 함수: _updateLoginTime');
        print('📍 URL: ${config.getApiBaseUrl()}/api/user_auth_identities/$authSeq/update_login_time');
        print('❌ 오류: $e');
        print('📚 스택 트레이스: $stackTrace');
        print('═══════════════════════════════════════════════════════');
      }
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
      if (kDebugMode) {
        print('🔵 [Login] 로그인 시작');
        print('   입력값: $input (이메일: $isEmail)');
      }
      
      // 1. user_auth_identities 테이블에서 provider='local'로 조회
      if (kDebugMode) {
        print('🔵 [Login] 인증 정보 조회 시작: provider=local');
      }
      
      final authResponse = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/user_auth_identities/provider/local',
        fromJson: (json) => json,
      );

      if (kDebugMode) {
        print('🔵 [Login] 인증 정보 조회 응답: success=${authResponse.success}, error=${authResponse.error}');
      }

      if (!authResponse.success || authResponse.data == null) {
        if (kDebugMode) {
          print('═══════════════════════════════════════════════════════');
          print('🚨 [ERROR] 함수: _handleLogin - 인증 정보 조회 실패');
          print('📍 URL: ${config.getApiBaseUrl()}/api/user_auth_identities/provider/local');
          print('❌ 오류: ${authResponse.error}');
          print('═══════════════════════════════════════════════════════');
        }
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '로그인 중 오류가 발생했습니다: ${authResponse.error}',
        );
        return;
      }

      // 2. 이메일 형식 검증 (이중 체크)
      if (!isEmail) {
        if (kDebugMode) {
          print('❌ [Login] 이메일 형식이 아님: $input');
        }
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '올바른 이메일 형식을 입력해주세요',
        );
        return;
      }

      // 3. provider_subject가 입력한 이메일과 일치하는 인증 정보 찾기
      final List<dynamic> authList = authResponse.data!['results'] ?? [];
      Map<String, dynamic>? foundAuth;
      
      if (kDebugMode) {
        print('🔵 [Login] 인증 정보 목록 개수: ${authList.length}');
      }
      
      for (var auth in authList) {
        if (auth['provider_subject'] == input) {
          foundAuth = auth as Map<String, dynamic>;
          break;
        }
      }

      if (foundAuth == null) {
        if (kDebugMode) {
          print('❌ [Login] 일치하는 인증 정보 없음: $input');
        }
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '이메일 또는 비밀번호가 올바르지 않습니다.',
        );
        return;
      }

      if (kDebugMode) {
        print('✅ [Login] 인증 정보 찾음: id=${foundAuth['id']}, u_seq=${foundAuth['u_seq']}');
      }

      // 4. 비밀번호 검증 (평문 비교 - 임시, 보안상 백엔드에서 해시 비교해야 함)
      if (foundAuth['password'] != password) {
        if (kDebugMode) {
          print('❌ [Login] 비밀번호 불일치');
        }
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '이메일 또는 비밀번호가 올바르지 않습니다.',
        );
        return;
      }

      if (kDebugMode) {
        print('✅ [Login] 비밀번호 검증 성공');
      }

      // 5. user 테이블에서 사용자 정보 조회
      final int uSeq = foundAuth['u_seq'] as int;
      
      if (kDebugMode) {
        print('🔵 [Login] 사용자 정보 조회 시작: u_seq=$uSeq');
      }
      
      final userResponse = await CustomNetworkUtil.get<Map<String, dynamic>>(
        '/api/users/$uSeq',
        fromJson: (json) => json,
      );

      if (kDebugMode) {
        print('🔵 [Login] 사용자 정보 조회 응답: success=${userResponse.success}, error=${userResponse.error}');
      }

      if (!userResponse.success || userResponse.data == null) {
        if (kDebugMode) {
          print('═══════════════════════════════════════════════════════');
          print('🚨 [ERROR] 함수: _handleLogin - 사용자 정보 조회 실패');
          print('📍 URL: ${config.getApiBaseUrl()}/api/users/$uSeq');
          print('❌ 오류: ${userResponse.error}');
          print('═══════════════════════════════════════════════════════');
        }
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
        if (kDebugMode) {
          print('⚠️ [Login] 탈퇴 회원 로그인 시도: ${user.uEmail}');
        }
        await _blockLogin('탈퇴한 회원입니다.', () => dialogShown = true);
        if (kDebugMode) {
          print('⚠️ [Login] 탈퇴 회원 체크 후 return - 로그인 프로세스 중단');
        }
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
        if (kDebugMode) {
          print('🔵 [Login] 로그인 시간 업데이트 시작: auth_seq=${authIdentity.authSeq}');
        }
        await _updateLoginTime(authIdentity.authSeq!);
      }

      // 10. 로그인 성공 처리
      if (kDebugMode) {
        print('✅ [Login] 로그인 성공: ${user.uName} (${user.uEmail})');
      }
      
      _handleLoginSuccess(user, authIdentity: authIdentity);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════');
        print('🚨 [ERROR] 함수: _handleLogin - 전체 프로세스 예외');
        print('❌ 오류: $error');
        print('📚 스택 트레이스: $stackTrace');
        print('═══════════════════════════════════════════════════════');
      }
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpView()),
    );
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpView(testData: testData),
      ),
    );
  }

  /// 구글 소셜 로그인 처리
  Future<void> _handleGoogleSignIn() async {
    // 다이얼로그가 표시되었는지 추적 (finally 블록에서 로딩 오버레이를 닫지 않도록)
    bool dialogShown = false;
    
    try {
      if (kDebugMode) {
        print('🔵 [GoogleLogin] 구글 로그인 시작');
      }
      
      // 구글 로그인 시도
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 사용자가 로그인을 취소한 경우
        if (kDebugMode) {
          print('⚠️ [GoogleLogin] 구글 로그인 취소됨 - 로그인 화면 유지');
        }
        // 취소 시 아무것도 하지 않고 로그인 화면에 머무름
        return;
      }

      // 로딩 오버레이 표시 (통신 중 다른 버튼 클릭 방지)
      CustomCommonUtil.showLoadingOverlay(context, message: '구글 로그인 중...');

      if (kDebugMode) {
        print('✅ [GoogleLogin] 구글 로그인 성공');
        print('   이메일: ${googleUser.email}');
        print('   이름: ${googleUser.displayName}');
        print('   ID: ${googleUser.id}');
      }
      
      // 1. 백엔드 API에 소셜 로그인 요청 (Form 데이터)
      if (kDebugMode) {
        print('🔵 [GoogleLogin] 소셜 로그인 API 호출 시작');
      }
      
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
      
      if (kDebugMode) {
        print('🔵 [GoogleLogin] 소셜 로그인 API 응답: status=${response.statusCode}');
        print('🔵 [GoogleLogin] 응답 본문: ${response.body}');
      }
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        final errorMsg = errorBody['errorMsg'] ?? '소셜 로그인 실패';
        if (kDebugMode) {
          print('❌ [GoogleLogin] 소셜 로그인 API 실패: $errorMsg');
        }
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '소셜 로그인 실패: $errorMsg',
        );
        return;
      }
      
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (responseData['result'] == 'Error') {
        final errorMsg = responseData['errorMsg'] ?? '소셜 로그인 실패';
        if (kDebugMode) {
          print('❌ [GoogleLogin] 소셜 로그인 API 에러: $errorMsg');
        }
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
      if (kDebugMode) {
        print('✅ [GoogleLogin] 로그인 성공: ${user.uName} (${user.uEmail})');
      }
      
      _handleLoginSuccess(user, authIdentity: authIdentity);
      
    } catch (error, stackTrace) {
      // 에러 상세 정보 출력
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════');
        print('🚨 [ERROR] 함수: _handleGoogleSignIn');
        print('❌ 오류: $error');
        print('📚 스택 트레이스: $stackTrace');
        print('═══════════════════════════════════════════════════════');
      }
      
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
