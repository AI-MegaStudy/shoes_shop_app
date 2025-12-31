class Refund {
  final int ref_seq;
  final String? created_at;
  final String? ref_reason;
  final int? ref_re_seq;
  final String? ref_re_content;
  final int u_seq;
  final int s_seq;
  final int pic_seq;

  Refund({
    required this.ref_seq,
    this.created_at,
    this.ref_reason,
    this.ref_re_seq,
    this.ref_re_content,
    required this.u_seq,
    required this.s_seq,
    required this.pic_seq,
  });

  Map<String, dynamic> toJson() {
    return {
      'ref_seq': ref_seq,
      'created_at': created_at,
      'ref_reason': ref_reason,
      'ref_re_seq': ref_re_seq,
      'ref_re_content': ref_re_content,
      'u_seq': u_seq,
      's_seq': s_seq,
      'pic_seq': pic_seq,
    };
  }

  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      ref_seq: json['ref_seq'] as int,
      created_at: json['created_at'] as String?,
      ref_reason: json['ref_reason'] as String?,
      ref_re_seq: json['ref_re_seq'] as int?,
      ref_re_content: json['ref_re_content'] as String?,
      u_seq: json['u_seq'] as int,
      s_seq: json['s_seq'] as int,
      pic_seq: json['pic_seq'] as int,
    );
  }
}