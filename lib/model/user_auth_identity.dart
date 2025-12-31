/// UserAuthIdentity 모델 클래스 (user_auth_identities 테이블 구조에 맞춤)
/// 소셜 로그인 지원 버전
class UserAuthIdentity {
  final int? authSeq;               // 인증 수단 고유 ID(PK)
  final int uSeq;                   // 고객 번호(FK)
  final String provider;            // 로그인 제공자(local, google, kakao)
  final String providerSubject;     // 제공자 고유 식별자
  final String? providerIssuer;     // 제공자 발급자
  final String? emailAtProvider;    // 제공자에서 받은 이메일
  final String? password;          // 로컬 로그인 비밀번호 (로컬만)
  final String? createdAt;         // 생성일자
  final String? lastLoginAt;        // 마지막 로그인 일시
  
  UserAuthIdentity({
    this.authSeq,
    required this.uSeq,
    required this.provider,
    required this.providerSubject,
    this.providerIssuer,
    this.emailAtProvider,
    this.password,
    this.createdAt,
    this.lastLoginAt,
  });
  
  /// JSON으로 변환 (GetStorage 저장용)
  Map<String, dynamic> toJson() {
    return {
      'authSeq': authSeq,
      'uSeq': uSeq,
      'provider': provider,
      'providerSubject': providerSubject,
      'providerIssuer': providerIssuer,
      'emailAtProvider': emailAtProvider,
      'password': password,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
    };
  }
  
  /// JSON에서 생성
  factory UserAuthIdentity.fromJson(Map<String, dynamic> json) {
    return UserAuthIdentity(
      authSeq: (json['auth_seq'] ?? json['authSeq']) as int?,
      uSeq: (json['u_seq'] ?? json['uSeq']) as int,
      provider: json['provider'] as String,
      providerSubject: (json['provider_subject'] ?? json['providerSubject']) as String,
      providerIssuer: json['provider_issuer'] ?? json['providerIssuer'] as String?,
      emailAtProvider: json['email_at_provider'] ?? json['emailAtProvider'] as String?,
      password: json['password'] as String?,
      createdAt: json['created_at'] ?? json['createdAt'] as String?,
      lastLoginAt: json['last_login_at'] ?? json['lastLoginAt'] as String?,
    );
  }
  
  /// 소셜 로그인 여부 확인
  bool get isSocialLogin => provider != 'local';
}

