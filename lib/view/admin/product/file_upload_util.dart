import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shoes_shop_app/config.dart' as config;

/// 파일 업로드 유틸리티
/// 이미지 및 GLB 파일 선택 및 업로드를 담당합니다.
class FileUploadUtil {
  /// 이미지 선택 (갤러리 또는 카메라)
  /// 
  /// [source] 이미지 소스 (갤러리 또는 카메라)
  /// 반환: 선택된 이미지 파일 경로, 취소 시 null
  static Future<String?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );

      return image?.path;
    } catch (e) {
      debugPrint('이미지 선택 오류: $e');
      return null;
    }
  }

  /// 파일 선택 (파일 시스템 접근)
  /// 
  /// [allowedExtensions] 허용할 파일 확장자 (예: ['jpg', 'png', 'glb'])
  /// [type] 파일 타입 필터
  /// 반환: 선택된 파일 경로, 취소 시 null
  static Future<String?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }
      return null;
    } catch (e) {
      debugPrint('파일 선택 오류: $e');
      return null;
    }
  }

  /// GLB 파일 선택
  /// 
  /// 반환: 선택된 GLB 파일 경로, 취소 시 null
  static Future<String?> pickGlbFile() async {
    return pickFile(
      allowedExtensions: ['glb'],
      type: FileType.custom,
    );
  }

  /// 이미지 파일 선택 (파일 시스템 또는 갤러리)
  /// 
  /// [useFileSystem] true면 파일 시스템 접근, false면 갤러리 접근
  /// 반환: 선택된 이미지 파일 경로, 취소 시 null
  static Future<String?> pickImageFile({
    bool useFileSystem = false,
  }) async {
    if (useFileSystem) {
      return pickFile(
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        type: FileType.image,
      );
    } else {
      return pickImage(source: ImageSource.gallery);
    }
  }

  /// 제품 이미지 업로드
  /// 
  /// [productSeq] 제품 번호
  /// [filePath] 업로드할 파일 경로
  /// 반환: 업로드 성공 시 file_url, 실패 시 null
  static Future<String?> uploadProductImage({
    required int productSeq,
    required String filePath,
  }) async {
    try {
      final apiBaseUrl = config.getApiBaseUrl();
      final uri = Uri.parse('$apiBaseUrl/api/products/$productSeq/upload_file');

      final request = http.MultipartRequest('POST', uri);
      request.fields['file_type'] = 'image';

      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('파일이 존재하지 않습니다: $filePath');
        return null;
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final responseData = response.body;
          // JSON 파싱
          try {
            final decoded = jsonDecode(responseData) as Map<String, dynamic>;
            if (decoded['result'] == 'OK') {
              return decoded['file_url'] as String?;
            } else {
              debugPrint('업로드 실패: ${decoded['errorMsg']}');
              return null;
            }
          } catch (e) {
            // 정규식으로 파싱 시도
            final match = RegExp(r'"file_url"\s*:\s*"([^"]+)"').firstMatch(responseData);
            if (match != null) {
              return match.group(1);
            }
            debugPrint('응답 파싱 실패: $responseData');
            return null;
          }
        } catch (e) {
          debugPrint('JSON 파싱 오류: $e');
          return null;
        }
      } else {
        debugPrint('업로드 실패: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('업로드 오류: $e');
      return null;
    }
  }

  /// 제품 GLB 모델 업로드
  /// 
  /// [productSeq] 제품 번호
  /// [filePath] 업로드할 GLB 파일 경로
  /// [modelName] 모델명 (예: 'nike_v2k')
  /// 반환: 업로드 성공 시 file_url, 실패 시 null
  static Future<String?> uploadProductModel({
    required int productSeq,
    required String filePath,
    required String modelName,
  }) async {
    try {
      final apiBaseUrl = config.getApiBaseUrl();
      final uri = Uri.parse('$apiBaseUrl/api/products/$productSeq/upload_file');

      final request = http.MultipartRequest('POST', uri);
      request.fields['file_type'] = 'glb';
      request.fields['model_name'] = modelName;

      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('파일이 존재하지 않습니다: $filePath');
        return null;
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final responseData = response.body;
          // JSON 파싱
          try {
            final decoded = jsonDecode(responseData) as Map<String, dynamic>;
            return decoded['file_url'] as String?;
          } catch (e) {
            // 정규식으로 파싱 시도
            final match = RegExp(r'"file_url"\s*:\s*"([^"]+)"').firstMatch(responseData);
            if (match != null) {
              return match.group(1);
            }
            debugPrint('응답 파싱 실패: $responseData');
            return null;
          }
        } catch (e) {
          debugPrint('JSON 파싱 오류: $e');
          return null;
        }
      } else {
        debugPrint('업로드 실패: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('업로드 오류: $e');
      return null;
    }
  }

  /// 파일 선택 다이얼로그 표시
  /// 
  /// [context] BuildContext
  /// [onImageSelected] 이미지 선택 시 콜백
  /// [onGlbSelected] GLB 파일 선택 시 콜백
  static Future<void> showFilePickerDialog({
    required BuildContext context,
    required Function(String filePath) onImageSelected,
    required Function(String filePath) onGlbSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('이미지 선택'),
                subtitle: const Text('파일 시스템에서 이미지 선택 (Files/다운로드 폴더)'),
                onTap: () async {
                  Navigator.pop(context);
                  // 파일 피커를 통해 이미지 선택 (iOS Files, Android 파일 관리자)
                  final path = await pickFile(
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
                    type: FileType.image,
                  );
                  if (path != null) {
                    onImageSelected(path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.model_training),
                title: const Text('GLB 모델 선택'),
                subtitle: const Text('3D 모델 파일 선택'),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await pickGlbFile();
                  if (path != null) {
                    onGlbSelected(path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('취소'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

