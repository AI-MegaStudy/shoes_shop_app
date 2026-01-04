import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o3d/o3d.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GTProductDetail3D extends StatefulWidget {
  final List<String>? imageNames;
  final List<String>? colorList;
  final int? initialIndex;

  const GTProductDetail3D({super.key, this.imageNames, this.colorList, this.initialIndex});

  @override
  State<GTProductDetail3D> createState() => _GTProductDetail3DState();
}

class _GTProductDetail3DState extends State<GTProductDetail3D> {
  // arguments에서 받을 데이터
  late List<String> _imageNames; // 이미지 파일명 리스트
  late int _initialIndex; // 초기 로딩할 인덱스 번호
  List<String>? _providedColorList; // 전달받은 색상 리스트 (선택적)

  // 이미지 파일명에서 추출한 모델 이름 리스트 (예: 'Newbalnce_U740WN2_Black')
  late List<String> _modelNameList;

  // 사용할 색상 리스트 (전달받은 것이 있으면 사용, 없으면 이미지명에서 추출)
  late List<String> _colorList;

  // 현재 선택된 인덱스
  late int _currentIndex;

  // 모델 로딩 상태
  bool _isLoading = false;

  // 위젯 강제 재생성을 위한 카운터 (같은 모델이라도 재로드하기 위해)
  int _reloadCounter = 0;

  // O3DController (o3d 패키지의 컨트롤러)
  O3DController controller = O3DController();

  // WebViewController 저장 (향후 로딩 취소 기능 추가 시 사용 가능)
  // ignore: unused_field
  WebViewController? _webViewController;

  // 현재 로딩 중인 URL 추적 (위젯 재생성 시 이전 로딩 무시용)
  String? _currentLoadingUrl;

  // 📐 카메라 초기 설정 값 (현재 사용 안 함 - 위젯 재생성 방식 사용)
  // static const double _initialTheta = 35.0; // 수평 회전 각도 (좌우)
  // static const double _initialPhi = 55.0; // 수직 회전 각도 (상하)
  // static const double _initialRadius = 260.0; // 카메라 거리 (줌: 작을수록 가까이, 클수록 멀리)

  // 현재 모델 이름 (인덱스 기반)
  String get _currentModelName => _modelNameList[_currentIndex];

  // PHP 파일 URL 생성 (GET 파라미터로 모델 이름 전달)
  String get _modelUrl => 'https://cheng80.myqnapcloud.com/glb_model.php?name=$_currentModelName';

  @override
  void initState() {
    super.initState();

    // 생성자로 전달받은 데이터 또는 Get.arguments에서 데이터 추출
    if (widget.imageNames != null && widget.imageNames!.isNotEmpty) {
      // 생성자로 전달받은 데이터 사용
      _imageNames = widget.imageNames!;
      _initialIndex = widget.initialIndex ?? 0;
      if (widget.colorList != null) {
        _providedColorList = widget.colorList;
      }
    } else {
      // Get.arguments에서 데이터 추출 (하위 호환성)
      final args = Get.arguments;
      if (args == null || args is! Map<String, dynamic>) {
        // arguments가 없으면 빈 리스트로 초기화 (에러 방지)
        _imageNames = [];
        _initialIndex = 0;
        _modelNameList = [];
        _colorList = [];
        _currentIndex = 0;
        return;
      }

      // imageNames 추출
      if (args['imageNames'] == null || args['imageNames'] is! List) {
        _imageNames = [];
        _initialIndex = 0;
        _modelNameList = [];
        _colorList = [];
        _currentIndex = 0;
        return;
      }
      _imageNames = List<String>.from(args['imageNames']);

      // initialIndex 추출 (선택적, 기본값: 0)
      _initialIndex = args['initialIndex'] as int? ?? 0;

      // colorList 추출 (선택적)
      if (args['colorList'] != null && args['colorList'] is List) {
        _providedColorList = List<String>.from(args['colorList']);
      }
    }

    // 이미지 파일명 리스트 파싱
    _parseImageNames();

    // 초기 인덱스 설정 (범위 체크)
    _currentIndex = _initialIndex;
    if (_currentIndex < 0 || _currentIndex >= _modelNameList.length) {
      _currentIndex = 0;
    }

    // 초기 로딩 시작 (onWebViewCreated가 호출되면 onPageStarted에서 업데이트됨)
    _isLoading = true;
  }

  @override
  void dispose() {
    // 위젯이 재생성될 때 이전 로딩 상태 무시
    _currentLoadingUrl = null;
    _webViewController = null;
    super.dispose();
  }

  // 이미지 파일명 파싱 함수
  void _parseImageNames() {
    _modelNameList = [];

    for (String imageName in _imageNames) {
      // 확장자 제거 (예: 'Newbalnce_U740WN2_Black_01.png' -> 'Newbalnce_U740WN2_Black_01')
      String nameWithoutExt = imageName.replaceAll(RegExp(r'\.(png|jpg|jpeg|avif)$'), '');

      // 마지막 언더스코어와 숫자 제거 (예: 'Newbalnce_U740WN2_Black_01' -> 'Newbalnce_U740WN2_Black')
      String modelName = nameWithoutExt.replaceAll(RegExp(r'_\d+$'), '');

      _modelNameList.add(modelName);
    }

    // 색상 리스트 설정: 전달받은 colorList가 있으면 사용, 없으면 이미지명에서 추출
    if (_providedColorList != null && _providedColorList!.length == _imageNames.length) {
      _colorList = List<String>.from(_providedColorList!);
    } else {
      // 이미지명에서 색상 추출
      _colorList = [];
      for (String imageName in _imageNames) {
        String nameWithoutExt = imageName.replaceAll(RegExp(r'\.(png|jpg|jpeg|avif)$'), '');
        String modelName = nameWithoutExt.replaceAll(RegExp(r'_\d+$'), '');
        List<String> parts = modelName.split('_');
        String color = parts.isNotEmpty ? parts.last : '';
        _colorList.add(color);
      }
    }
  }

  // 텍스처 색상 변경 함수 (현재 사용하지 않음 - 부모 쪽 색상 선택 사용)
  // 나중에 부모에서 색상 선택 시 3D 모델도 변경하려면 이 함수를 public으로 만들고 호출 가능하게 해야 함
  // void _changeTextureColor(String color) {
  //   // 로딩 중이면 무시
  //   if (_isLoading) {
  //     return;
  //   }
  //
  //   // 색상에 해당하는 인덱스 찾기
  //   int targetIndex = _colorList.indexOf(color);
  //   if (targetIndex == -1) {
  //     return;
  //   }
  //
  //   if (targetIndex == _currentIndex) {
  //     return;
  //   }
  //
  //   setState(() {
  //     _currentIndex = targetIndex;
  //     _isLoading = true; // 로딩 시작
  //   });
  //
  //   // O3D 위젯이 src 변경을 자동으로 감지하여 새 모델을 로드함
  //   // onWebViewCreated의 NavigationDelegate가 페이지 로딩 완료를 감지함
  // }

  // 현재 모델 리로드 함수 (현재 선택된 모델을 다시 로드)
  void _reloadInitialModel() {
    // 로딩 중이면 무시
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true; // 로딩 시작
      _reloadCounter++; // 위젯 강제 재생성을 위한 카운터 증가 (현재 인덱스 유지)
    });

    // O3D 위젯이 src 변경을 자동으로 감지하여 새 모델을 로드함 (ValueKey로 위젯 재생성)
    // onWebViewCreated의 NavigationDelegate가 페이지 로딩 완료를 감지함
    // _reloadCounter가 변경되면 위젯이 재생성되어 카메라가 초기화됨
    // _currentIndex는 변경하지 않으므로 현재 선택된 모델이 다시 로드됨

    debugPrint('=== 3D 모델 리로드 (detail_module_3d) ===');
    debugPrint('리로드 카운터: $_reloadCounter');
    debugPrint('현재 모델 이름: $_currentModelName');
    debugPrint('모델 URL: $_modelUrl');
    debugPrint('현재 색상 인덱스: $_currentIndex');
    debugPrint('==========================================');
  }

  @override
  Widget build(BuildContext context) {
    // 부모의 크기에 맞춰서 렌더링하기 위해 LayoutBuilder 사용
    return LayoutBuilder(
      builder: (context, constraints) {
        // 부모가 제공하는 최대 너비와 높이 사용
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;

        // 정사각형으로 만들되, 부모 크기를 초과하지 않도록
        // 너비와 높이 중 작은 값을 기준으로 정사각형 크기 결정
        final double size = availableHeight < availableWidth ? availableHeight : availableWidth;

        // 부모 크기에 맞춰서 3D 뷰어만 표시 (색상 선택은 부모 쪽에서 처리)
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              // 3D 모델 뷰어 (하단 레이어)
              Container(
                color: Colors.black,
                child: O3D(
                  key: ValueKey('${_modelUrl}_$_reloadCounter'), // 모델 URL과 reloadCounter 조합으로 위젯 재생성
                  controller: controller,
                  src: _modelUrl,
                  autoRotate: false, // 자동 회전 비활성화 (사용자가 직접 컨트롤)
                  cameraControls: true, // 카메라 컨트롤 활성화 (핀치 줌, 드래그 등)
                  onWebViewCreated: (WebViewController webViewController) {
                    // WebViewController 저장 (로딩 취소용)
                    _webViewController = webViewController;

                    // 현재 로딩 중인 URL 설정
                    final currentUrl = _modelUrl;
                    _currentLoadingUrl = currentUrl;

                    // NavigationDelegate를 설정하여 페이지 로딩 완료 감지
                    webViewController.setNavigationDelegate(
                      NavigationDelegate(
                        onPageStarted: (String url) {
                          // 위젯이 재생성되어 URL이 변경되었으면 이전 로딩 무시
                          if (_currentLoadingUrl != currentUrl) {
                            return;
                          }

                          if (mounted) {
                            setState(() {
                              _isLoading = true;
                            });
                          }
                        },
                        onPageFinished: (String url) {
                          // 위젯이 재생성되어 URL이 변경되었으면 이전 로딩 무시
                          if (_currentLoadingUrl != currentUrl) {
                            return;
                          }

                          // 페이지 로딩 완료 후 짧은 지연 (모델 렌더링 시간 고려)
                          Future.delayed(const Duration(milliseconds: 500), () {
                            // 위젯이 재생성되어 URL이 변경되었거나 dispose되었으면 무시
                            if (!mounted || _currentLoadingUrl != currentUrl) {
                              return;
                            }

                            setState(() {
                              _isLoading = false;
                            });
                          });
                        },
                        onWebResourceError: (WebResourceError error) {
                          // 위젯이 재생성되어 URL이 변경되었으면 이전 에러 무시
                          if (_currentLoadingUrl != currentUrl) {
                            return;
                          }

                          debugPrint('=== 3D 뷰어 WebView 에러 ===');
                          debugPrint('에러 설명: ${error.description}');
                          debugPrint('에러 코드: ${error.errorCode}');
                          debugPrint('요청 URL: ${error.url}');
                          debugPrint('현재 로딩 URL: $currentUrl');
                          debugPrint('==========================');

                          if (mounted && _currentLoadingUrl == currentUrl) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              // 리셋 버튼 (현재 선택된 모델을 다시 로드)
              // 모델이 있을 때만 표시
              if (_currentModelName.isNotEmpty)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _isLoading ? null : _reloadInitialModel,
                    backgroundColor: Colors.blue.withOpacity(_isLoading ? 0.4 : 0.8),
                    tooltip: _isLoading ? '로딩 중...' : '현재 모델 리로드',
                    heroTag: 'reload_initial',
                    mini: true,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : const Icon(Icons.refresh, color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================
// 변경 이력
// ============================================
// 2026-01-01: 김택권
//   - 3D 모델 뷰어 화면 생성
//   - o3d 패키지를 사용하여 GLB 모델 표시
//   - 이미지 파일명 리스트를 파싱하여 모델 이름과 색상 추출
//   - 색상 선택 버튼으로 모델 변경 기능
//   - 현재 모델 리로드 기능 (카메라 초기화)
//   - WebView NavigationDelegate를 통한 로딩 상태 감지
//   - color_name_to_color.dart를 사용하여 색상 버튼 색상 지정
//   - 정사각형 3D 뷰어 (화면 너비의 80%)
//   - 선택된 버튼 표시를 위한 일관된 테두리 스타일 (파란색 두꺼운 테두리)
// 2026-01-05: 
//   - 부모 Container 크기에 맞춰서 렌더링하도록 수정
//   - SingleChildScrollView 제거하고 LayoutBuilder 사용
//   - 부모가 제공하는 크기 제약에 맞춰 정사각형 3D 뷰어 크기 자동 조정
//   - WebView 크기가 부모 Container와 정확히 일치하도록 개선
//   - 리셋 버튼 개선: 모델이 있을 때만 표시되도록 조건 추가
//   - 리셋 버튼 클릭 시 현재 선택된 모델을 다시 로드하는 기능 확인 및 디버그 로그 추가
//   - 오버플로우 수정: 색상 선택 버튼 제거 (부모 쪽 색상 선택 사용)
//   - Column을 SizedBox로 변경하여 부모 크기 제약 내에서만 렌더링하도록 수정
//   - 사용하지 않는 import 및 함수 정리
//   - 로딩 취소 로직 추가: 위젯 재생성 시 이전 로딩 상태 무시
//   - _currentLoadingUrl 추적으로 위젯 재생성 시 이전 로딩 콜백 무시 처리
//   - dispose() 메서드 추가로 위젯 재생성 시 정리 로직 구현