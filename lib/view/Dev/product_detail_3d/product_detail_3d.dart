import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o3d/o3d.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shoes_shop_app/utils/color_name_to_color.dart';

class ProductDetail3D extends StatefulWidget {
  const ProductDetail3D({super.key});

  @override
  State<ProductDetail3D> createState() => _ProductDetail3DState();
}

class _ProductDetail3DState extends State<ProductDetail3D> {
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
    
    // GetX의 arguments에서 데이터 추출
    final args = Get.arguments;
    if (args == null || args is! Map<String, dynamic>) {
      throw Exception('ProductDetail3D: arguments가 필요합니다. imageNames와 initialIndex를 전달해주세요.');
    }
    
    // imageNames 추출
    if (args['imageNames'] == null || args['imageNames'] is! List) {
      throw Exception('ProductDetail3D: imageNames (List<String>)가 필요합니다.');
    }
    _imageNames = List<String>.from(args['imageNames']);
    
    // initialIndex 추출 (선택적, 기본값: 0)
    _initialIndex = args['initialIndex'] as int? ?? 0;
    
    // colorList 추출 (선택적)
    if (args['colorList'] != null && args['colorList'] is List) {
      _providedColorList = List<String>.from(args['colorList']);
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

  // 텍스처 색상 변경 함수
  void _changeTextureColor(String color) {
    // 로딩 중이면 무시
    if (_isLoading) {
      return;
    }
    
    // 색상에 해당하는 인덱스 찾기
    int targetIndex = _colorList.indexOf(color);
    if (targetIndex == -1) {
      return;
    }
    
    if (targetIndex == _currentIndex) {
      return;
    }
    
    setState(() {
      _currentIndex = targetIndex;
      _isLoading = true; // 로딩 시작
    });
    
    // O3D 위젯이 src 변경을 자동으로 감지하여 새 모델을 로드함
    // onWebViewCreated의 NavigationDelegate가 페이지 로딩 완료를 감지함
  }
  
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("3D 모델 뷰어"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // 3D 모델을 표시하는 영역 (정사각형)
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8, // 정사각형: width와 동일한 높이
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
                          // NavigationDelegate를 설정하여 페이지 로딩 완료 감지
                          webViewController.setNavigationDelegate(
                            NavigationDelegate(
                              onPageStarted: (String url) {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                }
                              },
                              onPageFinished: (String url) {
                                // 페이지 로딩 완료 후 짧은 지연 (모델 렌더링 시간 고려)
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // 초기 모델로 리로드 버튼 (우측 하단)
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 색상 선택 버튼들
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _colorList.asMap().entries.map((entry) {
                  int index = entry.key;
                  String color = entry.value;
                  bool isSelected = index == _currentIndex;
                  
                  // 색상 텍스트를 실제 Color로 변환
                  Color buttonColor = colorNameToColor(color, isSelected: isSelected);
                  
                  return Padding(
                    padding: EdgeInsets.only(right: index < _colorList.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: !_isLoading && !isSelected
                            ? () => _changeTextureColor(color)
                            : null,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: buttonColor,
                            shape: BoxShape.circle,
                            // 모든 버튼에 테두리 추가 (선택된 버튼은 두꺼운 파란색, 선택되지 않은 버튼은 얇은 회색)
                            border: Border.all(
                              color: isSelected 
                                  ? Colors.blue // 선택된 버튼: 파란색 테두리
                                  : Colors.grey.shade400, // 선택되지 않은 버튼: 회색 테두리
                              width: isSelected ? 3.0 : 1.5, // 선택된 버튼: 두꺼운 테두리 (3px), 선택되지 않은 버튼: 얇은 테두리 (1.5px)
                            ),
                          ),
                        ),
                      ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
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

