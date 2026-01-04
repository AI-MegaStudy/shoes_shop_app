import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/utils/admin_tablet_utils.dart';

class AdminProfileEditView extends StatefulWidget {
  const AdminProfileEditView({super.key});

  @override
  State<AdminProfileEditView> createState() => _AdminProfileEditViewState();
}

class _AdminProfileEditViewState extends State<AdminProfileEditView> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'AdminProfileEditForm');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  Map<String, dynamic>? _currentAdmin;
  String _email = '';
  bool _isLoading = false;
  
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
    _loadAdminData();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isTablet(context)) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('관리자 기능은 태블릿에서만 사용 가능합니다.')),
        );
      } else {
        lockTabletLandscape(context);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    unlockAllOrientations();
    super.dispose();
  }

  /// 관리자 정보 로드
  Future<void> _loadAdminData() async {
    try {
      final storage = GetStorage();
      final adminJson = storage.read<String>('admin'); // 'admin' 키 사용
      
      if (adminJson == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 정보를 찾을 수 없습니다.')),
        );
        return;
      }
      
      final admin = jsonDecode(adminJson) as Map<String, dynamic>;
      
      setState(() {
        _currentAdmin = admin;
        // Staff 모델 필드명 사용 (호환성을 위해 e_email, e_name도 지원)
        _email = admin['s_id'] ?? admin['e_email'] ?? admin['email'] ?? '';
        _nameController.text = admin['s_name'] ?? admin['e_name'] ?? admin['name'] ?? '';
        _phoneController.text = admin['s_phone'] ?? admin['e_phone_number'] ?? admin['phone'] ?? '';
      });
      
      // 서버에서 프로필 이미지 가져오기
      final sSeq = admin['s_seq'] as int?;
      if (sSeq != null) {
        await _loadProfileImageFromServer(sSeq);
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ [AdminProfileEdit] 관리자 정보 로드 에러: $error');
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관리자 정보를 불러오는 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                      padding: config.profileEditPadding,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                                  return _buildDefaultProfileImage(context);
                                                },
                                              )
                                            : _buildProfileImageDisplay(context),
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
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: p.textOnPrimary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: config.largeSpacing),

                            // 이메일 (읽기 전용)
                            TextFormField(
                              controller: TextEditingController(text: _email),
                              decoration: InputDecoration(
                                labelText: '이메일',
                                prefixIcon: const Icon(Icons.email),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: p.chipUnselectedBg,
                              ),
                              enabled: false,
                            ),
                            SizedBox(height: config.largeSpacing),

                            // 이름
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: '이름',
                                hintText: '이름을 입력하세요',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '이름을 입력해주세요';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: config.largeSpacing),

                            // 전화번호
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: '전화번호',
                                hintText: '전화번호를 입력하세요',
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '전화번호를 입력해주세요';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: config.largeSpacing),

                            // 비밀번호
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: '비밀번호',
                                hintText: '새 비밀번호 (변경하지 않으려면 비워두세요)',
                                prefixIcon: Icon(Icons.lock),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                            ),
                            SizedBox(height: config.largeSpacing),

                            // 비밀번호 확인
                            TextFormField(
                              controller: _passwordConfirmController,
                              decoration: const InputDecoration(
                                labelText: '비밀번호 확인',
                                hintText: '비밀번호 재입력',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                            ),
                            SizedBox(height: config.largeSpacing),

                            // 수정 버튼
                            SizedBox(
                              width: double.infinity,
                              height: config.defaultButtonHeight,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleUpdate,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text(
                                        '수정하기',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  void _handleUpdate() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();

    if (password.isNotEmpty) {
      if (passwordConfirm.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호 확인을 입력해주세요')),
        );
        return;
      }
      if (password != passwordConfirm) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 수정'),
        content: const Text('정말 수정하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performUpdate();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _performUpdate() async {
    if (_currentAdmin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관리자 정보를 찾을 수 없습니다')),
      );
      return;
    }

    // 필수 필드 확인
    final sSeq = _currentAdmin!['s_seq'] as int?;
    final sId = _currentAdmin!['s_id'] as String? ?? _currentAdmin!['e_email'] as String? ?? '';
    final brSeq = _currentAdmin!['br_seq'] as int? ?? 0;
    final currentPassword = _currentAdmin!['s_password'] as String? ?? '';

    if (sSeq == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관리자 정보가 올바르지 않습니다')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      // 비밀번호가 비어있으면 기존 비밀번호 사용
      final finalPassword = password.isNotEmpty ? password : currentPassword;

      // API 호출: 이미지가 변경되었을 때만 with_image 엔드포인트 사용
      final apiBaseUrl = config.getApiBaseUrl();
      final url = _isImageChanged && _selectedImageFile != null
          ? Uri.parse('$apiBaseUrl/api/staff/$sSeq/with_image')
          : Uri.parse('$apiBaseUrl/api/staff/$sSeq');
      
      final request = http.MultipartRequest('POST', url);
      request.fields['s_id'] = sId;
      request.fields['br_seq'] = brSeq.toString();
      request.fields['s_password'] = finalPassword;
      request.fields['s_name'] = name;
      request.fields['s_phone'] = phone;
      if (_currentAdmin!['s_rank'] != null) {
        request.fields['s_rank'] = _currentAdmin!['s_rank'].toString();
      }
      if (_currentAdmin!['s_superseq'] != null) {
        request.fields['s_superseq'] = _currentAdmin!['s_superseq'].toString();
      }
      if (_currentAdmin!['s_quit_date'] != null) {
        request.fields['s_quit_date'] = _currentAdmin!['s_quit_date'].toString();
      }
      
      // 이미지 파일 추가 (이미지가 변경되었을 때만)
      if (_isImageChanged && _selectedImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _selectedImageFile!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['result'] == 'OK') {
          // 로컬 스토리지 업데이트
          final updatedAdmin = {
            ..._currentAdmin!,
            's_name': name,
            's_phone': phone,
            's_password': finalPassword,
            // 호환성을 위한 필드도 업데이트
            'e_name': name,
            'e_email': sId,
            'name': name,
            'email': sId,
          };

          final storage = GetStorage();
          storage.write('admin', jsonEncode(updatedAdmin));
          
          // 이미지가 변경된 경우, 서버에서 최신 이미지 다시 로드
          if (_isImageChanged) {
            await _loadProfileImageFromServer(sSeq);
            // 이미지 변경 플래그 리셋
            setState(() {
              _isImageChanged = false;
              _selectedImageFile = null;
            });
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('개인정보가 수정되었습니다.')),
            );
            Navigator.of(context).pop(true);
          }
        } else {
          final errorMsg = responseData['errorMsg'] ?? '수정에 실패했습니다.';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('수정 실패: $errorMsg')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('수정 실패: 서버 오류 (${response.statusCode})')),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AdminProfileEdit] 수정 에러: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 중 오류 발생: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  /// 서버에서 프로필 이미지 가져오기
  Future<void> _loadProfileImageFromServer(int staffSeq) async {
    try {
      final apiBaseUrl = config.getApiBaseUrl();
      final uri = Uri.parse('$apiBaseUrl/api/staff/$staffSeq/profile_image');
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        // 성공적으로 이미지를 가져온 경우
        if (mounted) {
          setState(() {
            _serverProfileImageBytes = response.bodyBytes;
          });
        }
      } else {
        // 이미지가 없거나 에러인 경우 (404 등) 기본 이미지 사용
        if (mounted) {
          setState(() {
            _serverProfileImageBytes = null;
          });
        }
      }
    } catch (e) {
      // 에러 발생 시 기본 이미지 사용
      if (mounted) {
        setState(() {
          _serverProfileImageBytes = null;
        });
      }
      if (kDebugMode) {
        print('❌ [AdminProfileEdit] 프로필 이미지 로드 에러: $e');
      }
    }
  }
  
  /// 프로필 이미지 표시 위젯 생성
  Widget _buildProfileImageDisplay(BuildContext context) {
    // 서버에서 가져온 이미지가 있으면 표시, 없으면 기본 이미지
    if (_serverProfileImageBytes != null) {
      return Image.memory(
        _serverProfileImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultProfileImage(context);
        },
      );
    }
    return _buildDefaultProfileImage(context);
  }
  
  /// 기본 프로필 이미지 위젯
  Widget _buildDefaultProfileImage(BuildContext context) {
    final p = context.palette;
    return Image.asset(
      config.defaultProfileImage,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: p.divider,
          child: Icon(
            Icons.person,
            size: 60,
            color: p.textSecondary,
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: ${e.toString()}')),
        );
      }
    }
  }
}