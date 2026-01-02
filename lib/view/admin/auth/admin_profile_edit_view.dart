import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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
        // 기존 필드명 사용
        _email = admin['e_email'] ?? admin['email'] ?? '';
        _nameController.text = admin['e_name'] ?? admin['name'] ?? '';
        _phoneController.text = admin['e_phone_number'] ?? admin['phone'] ?? '';
      });
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

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      // TODO: 백엔드 API 호출
      // PUT /api/employees/{id}
      
      final updatedAdmin = {
        ..._currentAdmin!,
        'e_name': name,
        'e_phone_number': phone,
        if (password.isNotEmpty) 'e_password': password,
      };

      final storage = GetStorage();
      storage.write('admin', jsonEncode(updatedAdmin));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('개인정보가 수정되었습니다.')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AdminProfileEdit] 수정 에러: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정 중 오류 발생: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}