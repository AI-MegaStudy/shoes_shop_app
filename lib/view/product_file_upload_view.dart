import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shoes_shop_app/config.dart' as config;
import 'package:shoes_shop_app/theme/app_colors.dart';
import 'package:shoes_shop_app/utils/custom_common_util.dart';

/// 상품 파일 업로드 화면
/// 갤러리에서 이미지 또는 GLB 파일을 선택하여 서버에 업로드하는 화면
class ProductFileUploadView extends StatefulWidget {
  const ProductFileUploadView({super.key});

  @override
  State<ProductFileUploadView> createState() => _ProductFileUploadViewState();
}

class _ProductFileUploadViewState extends State<ProductFileUploadView> {
  /// Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>(debugLabel: 'ProductFileUploadForm');

  /// 상품 번호 입력 컨트롤러
  final TextEditingController _productSeqController = TextEditingController();

  /// 모델명 입력 컨트롤러 (GLB 파일용)
  final TextEditingController _modelNameController = TextEditingController();

  /// 선택된 파일 타입 ('image' 또는 'glb')
  String _selectedFileType = 'image';

  /// 선택된 파일
  XFile? _selectedFile;

  /// 이미지 피커 인스턴스
  final ImagePicker _imagePicker = ImagePicker();

  // PHP 웹서버 Base URL (나중에 config로 이동 예정)
  // TODO: 실제 PHP 웹서버 URL로 변경
  // static const String phpWebServerUrl = 'YOUR_PHP_WEB_SERVER_URL';

  @override
  void dispose() {
    _productSeqController.dispose();
    _modelNameController.dispose();
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
              title: const Text('파일 업로드'),
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
                            // 타이틀
                            Text(
                              '상품 파일 업로드',
                              style: config.largeTitleStyle,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: config.largeSpacing),

                            // 파일 타입 선택
                            Text(
                              '파일 타입',
                              style: config.boldLabelStyle,
                            ),
                            SizedBox(height: config.defaultSpacing),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('이미지'),
                                    value: 'image',
                                    groupValue: _selectedFileType,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedFileType = value!;
                                        _selectedFile = null; // 파일 타입 변경 시 선택한 파일 초기화
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('GLB 파일'),
                                    value: 'glb',
                                    groupValue: _selectedFileType,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedFileType = value!;
                                        _selectedFile = null; // 파일 타입 변경 시 선택한 파일 초기화
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: config.largeSpacing),

                            // 상품 번호 입력 필드
                            TextFormField(
                              controller: _productSeqController,
                              decoration: const InputDecoration(
                                labelText: '상품 번호',
                                hintText: '상품 번호를 입력하세요',
                                prefixIcon: Icon(Icons.tag),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '상품 번호를 입력해주세요';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return '올바른 숫자를 입력해주세요';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: config.largeSpacing),

                            // 모델명 입력 필드 (GLB 파일일 때만 표시)
                            if (_selectedFileType == 'glb') ...[
                              TextFormField(
                                controller: _modelNameController,
                                decoration: const InputDecoration(
                                  labelText: '모델명',
                                  hintText: '모델명을 입력하세요 (예: nike_v2k)',
                                  prefixIcon: Icon(Icons.label),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (_selectedFileType == 'glb') {
                                    if (value == null || value.trim().isEmpty) {
                                      return '모델명을 입력해주세요';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: config.largeSpacing),
                            ],

                            // 파일 선택 버튼
                            SizedBox(
                              width: double.infinity,
                              height: config.defaultButtonHeight,
                              child: OutlinedButton.icon(
                                onPressed: _pickFile,
                                icon: const Icon(Icons.folder_open),
                                label: Text(_selectedFile == null ? '파일 선택' : '파일 다시 선택'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: p.textPrimary,
                                ),
                              ),
                            ),
                            SizedBox(height: config.defaultSpacing),

                            // 선택된 파일 미리보기/정보
                            if (_selectedFile != null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: p.chipUnselectedBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: p.primary),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '선택된 파일',
                                      style: config.boldLabelStyle,
                                    ),
                                    SizedBox(height: config.defaultSpacing),
                                    Text(
                                      '파일명: ${_selectedFile!.name}',
                                      style: config.bodyTextStyle,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '경로: ${_selectedFile!.path}',
                                      style: config.smallTextStyle.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: config.defaultSpacing),
                                    // 이미지 미리보기
                                    if (_selectedFileType == 'image') ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_selectedFile!.path),
                                          height: 200,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 200,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(Icons.broken_image, size: 48),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ] else ...[
                                      // GLB 파일 정보
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: p.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.threed_rotation, size: 32),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'GLB 3D 모델 파일',
                                                    style: config.boldLabelStyle,
                                                  ),
                                                  Text(
                                                    _selectedFile!.name,
                                                    style: config.bodyTextStyle,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: config.largeSpacing),
                            ],

                            // 업로드 버튼
                            SizedBox(
                              width: double.infinity,
                              height: config.defaultButtonHeight,
                              child: ElevatedButton(
                                onPressed: _selectedFile != null ? _handleUpload : null,
                                child: const Text(
                                  '업로드',
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

  /// 파일 선택 (갤러리에서)
  Future<void> _pickFile() async {
    try {
      XFile? file;

      if (_selectedFileType == 'image') {
        // 이미지 선택 (갤러리)
        file = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 2000,
          maxHeight: 2000,
          imageQuality: 90,
        );
      } else {
        // GLB 파일 선택 (파일 시스템에서)
        // image_picker는 이미지만 지원하므로, 다른 패키지 필요할 수 있음
        // 현재는 갤러리에서 선택하는 것으로 처리 (실제로는 파일 매니저 사용 권장)
        file = await _imagePicker.pickImage(
          source: ImageSource.gallery,
        );
        // TODO: GLB 파일 선택을 위해서는 file_picker 패키지 사용 권장
      }

      if (file != null) {
        setState(() {
          _selectedFile = file;
        });

        if (kDebugMode) {
          print('✅ [ProductFileUpload] 파일 선택 완료: ${file.path}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProductFileUpload] 파일 선택 오류: $e');
      }
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '파일 선택 중 오류가 발생했습니다.',
      );
    }
  }

  /// 파일 업로드 처리
  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '파일을 선택해주세요.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final productSeq = int.parse(_productSeqController.text.trim());

    // 로딩 오버레이 표시
    CustomCommonUtil.showLoadingOverlay(context, message: '파일 업로드 중...');

    try {
      if (kDebugMode) {
        print('🔵 [ProductFileUpload] 파일 업로드 시작');
        print('   상품 번호: $productSeq');
        print('   파일 타입: $_selectedFileType');
        print('   파일 경로: ${_selectedFile!.path}');
      }

      // FastAPI 업로드 엔드포인트 호출
      final uri = Uri.parse('${config.getApiBaseUrl()}/api/products/$productSeq/upload_file');
      final request = http.MultipartRequest('POST', uri);

      request.fields['file_type'] = _selectedFileType;

      if (_selectedFileType == 'glb') {
        final modelName = _modelNameController.text.trim();
        if (modelName.isEmpty) {
          CustomCommonUtil.showErrorSnackbar(
            context: context,
            message: '모델명을 입력해주세요.',
          );
          return;
        }
        request.fields['model_name'] = modelName;
      }

      // 파일 추가
      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedFile!.path),
      );

      if (kDebugMode) {
        print('🔵 [ProductFileUpload] 업로드 요청 필드: ${request.fields}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('🔵 [ProductFileUpload] 업로드 API 응답: status=${response.statusCode}');
        print('🔵 [ProductFileUpload] 응답 본문: ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        final errorMsg = errorBody['errorMsg'] ?? '파일 업로드 실패';
        if (kDebugMode) {
          print('❌ [ProductFileUpload] 업로드 API 실패: $errorMsg');
        }
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '파일 업로드 실패: $errorMsg',
        );
        return;
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['result'] != 'OK') {
        final errorMsg = responseData['errorMsg'] ?? '파일 업로드 실패';
        if (kDebugMode) {
          print('❌ [ProductFileUpload] 업로드 API 에러: $errorMsg');
        }
        CustomCommonUtil.showErrorSnackbar(
          context: context,
          message: '파일 업로드 실패: $errorMsg',
        );
        return;
      }

      if (kDebugMode) {
        print('✅ [ProductFileUpload] 파일 업로드 성공');
      }

      CustomCommonUtil.showSuccessSnackbar(
        context: context,
        title: '업로드 완료',
        message: '파일이 성공적으로 업로드되었습니다.',
      );

      // 성공 후 화면 닫기
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ProductFileUpload] 파일 업로드 오류: $e');
      }
      CustomCommonUtil.showErrorSnackbar(
        context: context,
        message: '파일 업로드 중 오류가 발생했습니다: $e',
      );
    } finally {
      // 로딩 오버레이 숨기기
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

