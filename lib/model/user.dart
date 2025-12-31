/// User 모델 클래스 (user 테이블 구조에 맞춤)
/// 소셜 로그인 지원 버전
class User {
  final int? uSeq;           // 고객 고유 ID(PK)
  final String uEmail;       // 고객 이메일 (필수, UNIQUE)
  final String uName;        // 고객 이름 (필수)
  final String? uPhone;      // 고객 전화번호 (선택)
  final String? uAddress;   // 고객 주소 (선택)
  final String? uImage;      // 고객 프로필 이미지 (선택)
  final String? createdAt;   // 가입일자
  final String? uQuitDate;   // 탈퇴일자
  
  User({
    this.uSeq,
    required this.uEmail,
    required this.uName,
    this.uPhone,
    this.uAddress,
    this.uImage,
    this.createdAt,
    this.uQuitDate,
  });
  
  /// JSON으로 변환 (GetStorage 저장용)
  Map<String, dynamic> toJson() {
    return {
      'uSeq': uSeq,
      'uEmail': uEmail,
      'uName': uName,
      'uPhone': uPhone,
      'uAddress': uAddress,
      'uImage': uImage,
      'createdAt': createdAt,
      'uQuitDate': uQuitDate,
    };
  }
  
  /// JSON에서 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uSeq: json['uSeq'] as int?,
      uEmail: json['uEmail'] as String,
      uName: json['uName'] as String,
      uPhone: json['uPhone'] as String?,
      uAddress: json['uAddress'] as String?,
      uImage: json['uImage'] as String?,
      createdAt: json['createdAt'] as String?,
      uQuitDate: json['uQuitDate'] as String?,
    );
  }
}

