/// Staff 모델 클래스 (staff 테이블 구조에 맞춤)
class Staff {
  final int? s_seq;
  final String s_id;
  final int br_seq;
  final String s_password;
  final String? s_image;
  final String? s_rank;
  final String s_phone;
  final String s_name;
  final int? s_superseq;
  final String? created_at;
  final String? s_quit_date;
  
  Staff({
    this.s_seq,
    required this.s_id,
    required this.br_seq,
    required this.s_password,
    this.s_image,
    this.s_rank,
    required this.s_phone,
    required this.s_name,
    this.s_superseq,
    this.created_at,
    this.s_quit_date,
  });
  
  /// JSON으로 변환 (GetStorage 저장용)
  Map<String, dynamic> toJson() {
    return {
      's_seq': s_seq,
      's_id': s_id,
      'br_seq': br_seq,
      's_password': s_password,
      's_image': s_image,
      's_rank': s_rank,
      's_phone': s_phone,
      's_name': s_name,
      's_superseq': s_superseq,
      'created_at': created_at,
      's_quit_date': s_quit_date,
      // 기존 admin_drawer_menu와 호환을 위한 필드
      'e_name': s_name,
      'e_email': s_id, // s_id를 이메일로 사용
      'name': s_name,
      'email': s_id,
    };
  }
  
  /// JSON에서 생성
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      s_seq: json['s_seq'] as int?,
      s_id: json['s_id'] as String? ?? json['e_email'] as String? ?? json['email'] as String? ?? '',
      br_seq: json['br_seq'] as int? ?? 0,
      s_password: json['s_password'] as String? ?? '',
      s_image: json['s_image'] as String?,
      s_rank: json['s_rank'] as String?,
      s_phone: json['s_phone'] as String? ?? '',
      s_name: json['s_name'] as String? ?? json['e_name'] as String? ?? json['name'] as String? ?? '',
      s_superseq: json['s_superseq'] as int?,
      created_at: json['created_at'] as String?,
      s_quit_date: json['s_quit_date'] as String?,
    );
  }
}

