import 'package:flutter/material.dart';


/// 큰 제목 텍스트 스타일 (프로필 화면 제목 등)
const TextStyle largeTitleStyle = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);

/// 제목 텍스트 스타일 (섹션 제목 등)
const TextStyle titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

/// 기본 텍스트 스타일 (본문)
const TextStyle bodyTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);

/// 중간 텍스트 스타일 (중요한 정보)
const TextStyle mediumTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Color(0xFF364151));

/// 작은 텍스트 스타일 (부가 정보)
const TextStyle smallTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

//  UI Text Styles - AppBar & Form Labels
/// 색상은 copyWith(color: ...)로 테마에 맞게 설정해야 함
const TextStyle boldLabelStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

// b_status 제공
const TextStyle boldWhiteStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15);

// 색상 지정
class PColor {
  static Color backgroundColor = const Color(0xFFF9FAFB);
  static Color dividerColor = Colors.grey[300]!;
}

class StatusConfig {
  static Color bStatusColor(dynamic status) {
    // int.parse는 에러 발생 위험이 있으므로 안전하게 처리
    final intValue = int.tryParse(status?.toString() ?? '');

// Pickup 상태
    return switch (intValue) {
      0 => Colors.grey,
      1 => Colors.blue,
      2 => Colors.orange,
      3 => Colors.green,
      _ => Colors.red,
    };
  }
}

Map pickupStatus = {
  0 : '준비 중',
  1 : '준비 완료',
  2 : '수령 완료',
  3 : '반품 완료'
};

// 앱바 디자인
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AdminAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 23,
        ),
      ),
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 60,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey[300],
          height: 1.0,
        ),
      ),
    );
  }

  // 앱바의 높이를 지정 (toolbarHeight + bottom 선의 두께)
  @override
  Size get preferredSize => const Size.fromHeight(61.0);
}

