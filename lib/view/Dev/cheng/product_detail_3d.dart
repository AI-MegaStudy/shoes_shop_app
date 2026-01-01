import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o3d/o3d.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProductDetail3D extends StatefulWidget {
  const ProductDetail3D({super.key});

  @override
  State<ProductDetail3D> createState() => _ProductDetail3DState();
}

class _ProductDetail3DState extends State<ProductDetail3D> {
  // arguments에서 받을 데이터
  late List<String> _imageNames; // 이미지 파일명 리스트
  late int _initialIndex; // 초기 로딩할 인덱스 번호
  
  // 이미지 파일명에서 추출한 모델 이름 리스트 (예: 'Newbalnce_U740WN2_Black')
  late List<String> _modelNameList;
  
  // 이미지 파일명에서 추출한 색상 리스트 (예: 'Black')
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
    
    debugPrint('📥 Get.arguments에서 데이터 수신:');
    debugPrint('   imageNames: $_imageNames');
    debugPrint('   initialIndex: $_initialIndex');
    
    // 이미지 파일명 리스트 파싱
    _parseImageNames();
    
    // 초기 인덱스 설정 (범위 체크)
    _currentIndex = _initialIndex;
    if (_currentIndex < 0 || _currentIndex >= _modelNameList.length) {
      debugPrint('⚠️ 초기 인덱스($_initialIndex)가 범위를 벗어났습니다. 0으로 설정합니다.');
      _currentIndex = 0;
    }
    
    debugPrint('📋 파싱된 모델 이름 리스트: $_modelNameList');
    debugPrint('🎨 파싱된 색상 리스트: $_colorList');
    debugPrint('🔄 초기 모델 URL: $_modelUrl');
    
    // 초기 로딩 시작 (onWebViewCreated가 호출되면 onPageStarted에서 업데이트됨)
    _isLoading = true;
  }
  
  // 이미지 파일명 파싱 함수
  void _parseImageNames() {
    _modelNameList = [];
    _colorList = [];
    
    for (String imageName in _imageNames) {
      // 확장자 제거 (예: 'Newbalnce_U740WN2_Black_01.png' -> 'Newbalnce_U740WN2_Black_01')
      String nameWithoutExt = imageName.replaceAll(RegExp(r'\.(png|jpg|jpeg|avif)$'), '');
      
      // 마지막 언더스코어와 숫자 제거 (예: 'Newbalnce_U740WN2_Black_01' -> 'Newbalnce_U740WN2_Black')
      String modelName = nameWithoutExt.replaceAll(RegExp(r'_\d+$'), '');
      
      // 색상 추출 (마지막 언더스코어 이후 부분, 예: 'Black')
      List<String> parts = modelName.split('_');
      String color = parts.isNotEmpty ? parts.last : '';
      
      _modelNameList.add(modelName);
      _colorList.add(color);
    }
  }

  // 텍스처 색상 변경 함수
  void _changeTextureColor(String color) {
    // 로딩 중이면 무시
    if (_isLoading) {
      debugPrint('⏳ 모델 로딩 중입니다. 잠시 후 다시 시도해주세요.');
      return;
    }
    
    // 색상에 해당하는 인덱스 찾기
    int targetIndex = _colorList.indexOf(color);
    if (targetIndex == -1) {
      debugPrint('⚠️ 색상을 찾을 수 없습니다: $color');
      return;
    }
    
    if (targetIndex == _currentIndex) {
      debugPrint('ℹ️ 이미 선택된 색상입니다: $color');
      return;
    }
    
    debugPrint('🔄 모델 변경: ${_colorList[_currentIndex]} -> $color');
    debugPrint('   모델 이름: ${_modelNameList[targetIndex]}');
    debugPrint('   모델 URL: https://cheng80.myqnapcloud.com/glb_model.php?name=${_modelNameList[targetIndex]}');
    
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
      debugPrint('⏳ 모델 로딩 중입니다. 잠시 후 다시 시도해주세요.');
      return;
    }
    
    debugPrint('🔄 현재 모델 리로드: ${_colorList[_currentIndex]}');
    debugPrint('   모델 이름: ${_modelNameList[_currentIndex]}');
    
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
                                debugPrint('📄 페이지 로딩 시작: $url');
                                if (mounted) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                }
                              },
                              onPageFinished: (String url) {
                                debugPrint('✅ 페이지 로딩 완료: $url');
                                // 페이지 로딩 완료 후 짧은 지연 (모델 렌더링 시간 고려)
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    debugPrint('✅ 모델 로딩 완료로 간주');
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
                  
                  // 색상에 따른 Material 색상 결정
                  Color buttonColor;
                  if (color.toLowerCase().contains('black')) {
                    buttonColor = isSelected 
                        ? Colors.black 
                        : Colors.black.withOpacity(0.6);
                  } else if (color.toLowerCase().contains('white')) {
                    buttonColor = isSelected 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.6);
                  } else if (color.toLowerCase().contains('gray') || 
                             color.toLowerCase().contains('grey')) {
                    buttonColor = isSelected 
                        ? Colors.grey 
                        : Colors.grey.withOpacity(0.6);
                  } else {
                    buttonColor = isSelected 
                        ? Colors.grey[700]! 
                        : Colors.grey.withOpacity(0.6);
                  }
                  
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
                                  ? Colors.red // 선택된 버튼: 파란색 테두리
                                  : Colors.black, // 선택되지 않은 버튼: 회색 테두리
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
