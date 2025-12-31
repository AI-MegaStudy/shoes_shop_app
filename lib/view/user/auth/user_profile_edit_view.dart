import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/model/user.dart';
import 'package:shoes_shop_app/model/user_auth_identity.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';


/// 사용자 개인정보 수정 화면
/// 사용자가 자신의 개인정보를 수정할 수 있는 화면입니다.
/// 이메일은 아이디 역할을 하므로 수정할 수 없습니다.

class UserProfileEditView extends StatefulWidget {
  const UserProfileEditView({super.key});

  @override
  State<UserProfileEditView> createState() => _UserProfileEditViewState();
}

class _UserProfileEditViewState extends State<UserProfileEditView> {
  /// Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>(debugLabel: 'UserProfileEditForm');

  /// 이름 입력 컨트롤러
  final TextEditingController _nameController = TextEditingController();

  /// 전화번호 입력 컨트롤러
  final TextEditingController _phoneController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  /// 비밀번호 확인 입력 컨트롤러
  final TextEditingController _passwordConfirmController = TextEditingController();

  /// 현재 사용자 정보
  User? _currentUser;
  
  /// 현재 사용자 인증 정보 (소셜 로그인 여부 확인용)
  UserAuthIdentity? _currentAuthIdentity;

  /// 이메일 (수정 불가, 읽기 전용)
  String _email = '';
  
  /// 소셜 로그인 여부 (로컬 로그인이 아니면 비밀번호 수정 불가)
  bool _isSocialLogin = false;

  /// 이미지 변경 여부 (사용자가 새로운 이미지를 선택했는지 추적)
  bool _isImageChanged = false;

  /// 선택된 프로필 이미지 파일
  XFile? _selectedImageFile;

  /// 서버에서 가져온 프로필 이미지 (bytes)
  Uint8List? _serverProfileImageBytes;

  /// 이미지 피커 인스턴스
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  /// 사용자 정보 로드 및 폼 채우기
  Future<void> _loadUserData() async {
    try {
      final storage = GetStorage();
      
      // GetStorage에서 User 정보 로드
      final userJson = storage.read<String>('user');
      if (userJson == null) {
        Navigator.of(context).pop();
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '로그인 정보를 찾을 수 없습니다.',
        );
        return;
      }
      
      final user = User.fromJson(jsonDecode(userJson));
      
      // GetStorage에서 UserAuthIdentity 정보 로드 (소셜 로그인 여부 확인용)
      final authIdentityJson = storage.read<String>('user_auth_identity');
      UserAuthIdentity? authIdentity;
      if (authIdentityJson != null) {
        authIdentity = UserAuthIdentity.fromJson(jsonDecode(authIdentityJson));
      }
      
          setState(() {
        _currentUser = user;
        _currentAuthIdentity = authIdentity;
        _email = user.uEmail;
        _nameController.text = user.uName;
        _phoneController.text = user.uPhone ?? '';
        // 소셜 로그인 여부 확인 (provider가 'local'이 아니면 소셜 로그인)
        _isSocialLogin = authIdentity?.isSocialLogin ?? false;
      });
      
      // 서버에서 프로필 이미지 가져오기
      if (user.uSeq != null) {
        await _loadProfileImageFromServer(user.uSeq!);
      }
      } catch (error) {
      // TODO: AppLogger 임시로 막음
      // AppLogger.e('사용자 정보 로드 에러', tag: 'UserProfileEdit', error: error);
      Navigator.of(context).pop();
      CustomCommonUtil.showErrorSnackbar(
        context: context,
          message: '사용자 정보를 불러오는 중 오류가 발생했습니다.',
      );
    }
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
              title: const Text('개인정보 수정'),
              centerTitle: true,
              titleTextStyle: config.boldLabelStyle.copyWith(color: p.textPrimary),
              backgroundColor: p.background,
              foregroundColor: p.textPrimary,
            ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: config.dialogMaxWidth),
                child: Padding(
                  padding: config.userProfileEditPadding,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 개인정보 수정 타이틀
                        Text(
                          '개인정보 수정',
                          style: config.largeTitleStyle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: config.largeSpacing),
                        // 프로필 이미지 선택 영역
                        Center(
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: p.primary,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _selectedImageFile != null
                                        ? Image.file(
                                            File(_selectedImageFile!.path),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              if (kDebugMode) {
                                                print('❌ [UserProfileEdit] 이미지 디코딩 오류: $error');
                                              }
                                              return _buildDefaultProfileImage();
                                            },
                                          )
                                        : _buildProfileImageDisplay(),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: p.primary,
                                      border: Border.all(
                                        color: p.background,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: config.largeSpacing),
                        // 이메일 입력 필드 (읽기 전용, 수정 불가)
                        TextFormField(
                          controller: TextEditingController(text: _email),
                          decoration: InputDecoration(
                            labelText: '이메일 (아이디)',
                            hintText: '이메일',
                            prefixIcon: const Icon(Icons.email),
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: p.chipUnselectedBg,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          enabled: false, // 수정 불가
                        ),
                        SizedBox(height: config.largeSpacing),
                        // 이름 입력 필드
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                          labelText: '이름',
                          hintText: '이름을 입력하세요',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return '이름을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: config.largeSpacing),
                        // 전화번호 입력 필드 (선택사항)
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: '전화번호 (선택사항)',
                          hintText: '전화번호를 입력하세요',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            // 전화번호는 선택사항이므로 빈 값 허용
                            return null;
                          },
                        ),
                        SizedBox(height: config.largeSpacing),
                        // 비밀번호 입력 필드 (로컬 로그인 사용자만 표시)
                        if (!_isSocialLogin) ...[
                          TextFormField(
                          controller: _passwordController,
                            decoration: const InputDecoration(
                          labelText: '비밀번호',
                          hintText: '새 비밀번호를 입력하세요 (변경하지 않으려면 비워두세요)',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                          obscureText: true,
                        ),
                          SizedBox(height: config.largeSpacing),
                        // 비밀번호 확인 입력 필드
                          TextFormField(
                          controller: _passwordConfirmController,
                            decoration: const InputDecoration(
                          labelText: '비밀번호 확인',
                          hintText: '비밀번호를 다시 입력하세요 (변경하지 않으려면 비워두세요)',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(),
                            ),
                          obscureText: true,
                          ),
                          SizedBox(height: config.largeSpacing),
                        ] else ...[
                          // 소셜 로그인 사용자 안내 메시지
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: p.primary, size: 20),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      '소셜 로그인 사용자는 비밀번호를 변경할 수 없습니다.',
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),
                          SizedBox(height: config.largeSpacing),
                        ],
                        // 수정하기 버튼
                        SizedBox(
                          width: double.infinity,
                          height: config.defaultButtonHeight,
                          child: ElevatedButton(
                            onPressed: _handleUpdate,
                            child: const Text(
                              '수정하기',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: config.largeSpacing),
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

  /// 서버에서 프로필 이미지 가져오기
  Future<void> _loadProfileImageFromServer(int userSeq) async {
    try {
      final uri = Uri.parse('${config.getApiBaseUrl()}/api/users/$userSeq/profile_image');
      
      if (kDebugMode) {
        print('🔵 [UserProfileEdit] 프로필 이미지 로드 시작: $uri');
      }
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        // 성공적으로 이미지를 가져온 경우
        if (mounted) {
          setState(() {
            _serverProfileImageBytes = response.bodyBytes;
          });
        }
        if (kDebugMode) {
          print('✅ [UserProfileEdit] 프로필 이미지 로드 성공 (크기: ${response.bodyBytes.length} bytes)');
        }
      } else {
        // 이미지가 없거나 에러인 경우 (404 등)
        if (kDebugMode) {
          print('⚠️ [UserProfileEdit] 프로필 이미지 없음 또는 에러: status=${response.statusCode}');
        }
        // 기본 이미지 사용 (상태 변경 불필요)
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserProfileEdit] 프로필 이미지 로드 오류: $e');
      }
      // 에러 발생 시 기본 이미지 사용
    }
  }

  /// 프로필 이미지 표시 위젯 생성
  Widget _buildProfileImageDisplay() {
    // 서버에서 가져온 이미지가 있으면 표시, 없으면 기본 이미지
    if (_serverProfileImageBytes != null) {
      return Image.memory(
        _serverProfileImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('❌ [UserProfileEdit] 서버 이미지 디코딩 오류: $error');
          }
          return _buildDefaultProfileImage();
        },
      );
    }
    return _buildDefaultProfileImage();
  }

  /// 기본 프로필 이미지 위젯
  Widget _buildDefaultProfileImage() {
    return Image.asset(
      config.defaultProfileImage,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.person,
            size: 60,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  /// 프로필 이미지 선택
  Future<void> _pickProfileImage() async {
    try {
      // 갤러리에서 이미지 선택
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = image;
          _isImageChanged = true;
        });
        
        if (kDebugMode) {
          print('✅ [UserProfileEdit] 이미지 선택 완료: ${image.path}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UserProfileEdit] 이미지 선택 오류: $e');
      }
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '이미지 선택 중 오류가 발생했습니다.',
      );
    }
  }


  /// 수정하기 버튼 클릭 처리
  void _handleUpdate() {
    _unfocusKeyboard();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      FocusScope.of(context).requestFocus(FocusNode());
      CustomCommonUtil.showErrorSnackbar(context: context, message: '이름을 입력해주세요');
      return;
    }

    // 전화번호는 선택사항이므로 검증 제거

    // 비밀번호 검증 (로컬 로그인 사용자만)
    if (!_isSocialLogin) {
    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();

    if (password.isNotEmpty) {
      if (passwordConfirm.isEmpty) {
          CustomCommonUtil.showErrorSnackbar(context: context, message: '비밀번호 확인을 입력해주세요');
        return;
      }
      if (password != passwordConfirm) {
          CustomCommonUtil.showErrorSnackbar(context: context, message: '비밀번호가 일치하지 않습니다');
        return;
      }
    } else {
      if (passwordConfirm.isNotEmpty) {
          CustomCommonUtil.showErrorSnackbar(context: context, message: '비밀번호를 입력하지 않으려면 비밀번호 확인도 비워두세요');
        return;
        }
      }
    }

    final scaffoldContext = context;

    CustomCommonUtil.showConfirmDialog(
      context: context,
      title: '개인정보 수정 확인',
      message: '정말 수정하시겠습니까?',
      confirmText: '확인',
      cancelText: '취소',
      onConfirm: () async {
        try {
          final success = await _performUpdate();
          if (success) {
            // 화면 닫기 (true 반환하여 상위 화면에 성공 알림)
            if (scaffoldContext.mounted) {
              Navigator.of(scaffoldContext).pop(true);
            }
          }
        } catch (e) {
          // TODO: AppLogger 임시로 막음
          // AppLogger.e('업데이트 중 예외 발생', tag: 'UserProfileEdit', error: e);
          if (scaffoldContext.mounted) {
            CustomCommonUtil.showErrorSnackbar(context: scaffoldContext, message: '업데이트 중 오류가 발생했습니다: $e');
        }
        }
      },
    );
  }

  /// 실제 업데이트 수행
  Future<bool> _performUpdate() async {
    if (_currentUser == null || _currentUser!.uSeq == null) {
      // TODO: AppLogger 임시로 막음
      // AppLogger.e('사용자 정보가 null입니다', tag: 'UserProfileEdit');
      CustomCommonUtil.showErrorSnackbar(context: context, message: '사용자 정보를 찾을 수 없습니다');
      return false;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    // 로딩 오버레이 표시 (통신 중 다른 버튼 클릭 방지)
    CustomCommonUtil.showLoadingOverlay(context, message: '정보 수정 중...');

    try {
      if (kDebugMode) {
        print('🔵 [UserProfileEdit] 사용자 정보 업데이트 시작: u_seq=${_currentUser!.uSeq}');
      }

      // 2. 백엔드 API 호출하여 사용자 정보 업데이트
      // 이미지가 변경되었을 때만 이미지 포함 엔드포인트 사용
      final uri = _isImageChanged && _selectedImageFile != null
          ? Uri.parse('${config.getApiBaseUrl()}/api/users/${_currentUser!.uSeq}/with_image')
          : Uri.parse('${config.getApiBaseUrl()}/api/users/${_currentUser!.uSeq}');
      
      if (kDebugMode) {
        print('🔵 [UserProfileEdit] 업데이트 URI: $uri (이미지 변경: $_isImageChanged)');
      }
      
      final request = http.MultipartRequest('POST', uri);

      request.fields['u_email'] = _email;
      request.fields['u_name'] = name;
      request.fields['u_phone'] = phone.isNotEmpty ? phone : '';
      request.fields['u_address'] = _currentUser!.uAddress ?? '';

      // 이미지 파일 추가 (이미지가 변경되었을 때만)
      if (_isImageChanged && _selectedImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _selectedImageFile!.path,
          ),
        );
        if (kDebugMode) {
          print('🔵 [UserProfileEdit] 선택한 이미지 사용: ${_selectedImageFile!.path}');
        }
      }

      if (kDebugMode) {
        print('🔵 [UserProfileEdit] 업데이트 요청 필드: ${request.fields}');
        print('🔵 [UserProfileEdit] 이미지 파일 추가 완료');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('🔵 [UserProfileEdit] 업데이트 API 응답: status=${response.statusCode}');
        print('🔵 [UserProfileEdit] 응답 본문: ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        final errorMsg = errorBody['errorMsg'] ?? '사용자 정보 업데이트 실패';
        if (kDebugMode) {
          print('❌ [UserProfileEdit] 업데이트 API 실패: $errorMsg');
        }
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '사용자 정보 업데이트 실패: $errorMsg',
        );
        return false;
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['result'] != 'OK') {
        final errorMsg = responseData['errorMsg'] ?? '사용자 정보 업데이트 실패';
        if (kDebugMode) {
          print('❌ [UserProfileEdit] 업데이트 API 에러: $errorMsg');
        }
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '사용자 정보 업데이트 실패: $errorMsg',
        );
        return false;
      }

      if (kDebugMode) {
        print('✅ [UserProfileEdit] 사용자 정보 업데이트 성공');
      }

      // 2. 로컬 로그인 사용자인 경우 비밀번호도 업데이트 (향후 구현)
      // TODO: user_auth_identities 테이블의 password 업데이트 API 구현 필요

      // 3. GetStorage에 업데이트된 사용자 정보 저장
      final updatedUser = User(
        uSeq: _currentUser!.uSeq,
        uEmail: _email,
        uName: name,
        uPhone: phone.isNotEmpty ? phone : null,
        uAddress: _currentUser!.uAddress,
        uImage: _currentUser!.uImage,
        createdAt: _currentUser!.createdAt,
        uQuitDate: _currentUser!.uQuitDate,
      );

      final storage = GetStorage();
      storage.write('user', jsonEncode(updatedUser.toJson()));

      // 이미지가 변경된 경우, 서버에서 최신 이미지 다시 로드
      if (_isImageChanged && _currentUser!.uSeq != null) {
        await _loadProfileImageFromServer(_currentUser!.uSeq!);
        // 이미지 변경 플래그 리셋
        setState(() {
          _isImageChanged = false;
          _selectedImageFile = null;
        });
      }

      // 로컬 로그인 사용자인 경우 비밀번호도 로컬에 저장 (임시, 실제로는 API 호출 필요)
      if (!_isSocialLogin && password.isNotEmpty && _currentAuthIdentity != null) {
        final updatedAuthIdentity = UserAuthIdentity(
          authSeq: _currentAuthIdentity!.authSeq,
          uSeq: _currentAuthIdentity!.uSeq,
          provider: _currentAuthIdentity!.provider,
          providerSubject: _currentAuthIdentity!.providerSubject,
          providerIssuer: _currentAuthIdentity!.providerIssuer,
          emailAtProvider: _currentAuthIdentity!.emailAtProvider,
          password: password, // 새 비밀번호 (실제로는 해시화 필요)
          createdAt: _currentAuthIdentity!.createdAt,
          lastLoginAt: _currentAuthIdentity!.lastLoginAt,
        );
        storage.write('user_auth_identity', jsonEncode(updatedAuthIdentity.toJson()));
      }

      CustomCommonUtil.showSuccessSnackbar(
        context: context,
        title: '수정 완료',
        message: '개인정보가 수정되었습니다.',
      );

      return true;
    } catch (e) {
      // TODO: AppLogger 임시로 막음
      // AppLogger.e('개인정보 수정 에러', tag: 'UserProfileEdit', error: e);
      CustomCommonUtil.showErrorSnackbar(context: context, message: '개인정보 수정 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      // 로딩 오버레이 숨기기 (성공/실패 여부와 관계없이 항상 실행)
      if (mounted) {
        try {
          CustomCommonUtil.hideLoadingOverlay(context);
        } catch (e) {
          // 이미 닫혔을 수 있으므로 무시
        }
      }
    }
  }
}

