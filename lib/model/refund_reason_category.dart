class RefundReasonCategory {
  final int ref_re_seq;
  final String ref_re_name;

  RefundReasonCategory({
    required this.ref_re_seq,
    required this.ref_re_name,
  });

  Map<String, dynamic> toJson() {
    return {
      'ref_re_seq': ref_re_seq,
      'ref_re_name': ref_re_name,
    };
  }

  factory RefundReasonCategory.fromJson(Map<String, dynamic> json) {
    return RefundReasonCategory(
      ref_re_seq: json['ref_re_seq'] as int,
      ref_re_name: json['ref_re_name'] as String,
    );
  }
}