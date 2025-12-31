class Request {
  final int req_seq;
  final String? created_at;
  final String? req_content;
  final int req_quantity;
  final String? req_manappdate;
  final String? req_dirappdate;
  final int s_seq;
  final int p_seq;
  final int m_seq;
  final int? s_superseq;

  Request({
    required this.req_seq,
    this.created_at,
    this.req_content,
    required this.req_quantity,
    this.req_manappdate,
    this.req_dirappdate,
    required this.s_seq,
    required this.p_seq,
    required this.m_seq,
    this.s_superseq,
  });

  Map<String, dynamic> toJson() {
    return {
      'req_seq': req_seq,
      'created_at': created_at,
      'req_content': req_content,
      'req_quantity': req_quantity,
      'req_manappdate': req_manappdate,
      'req_dirappdate': req_dirappdate,
      's_seq': s_seq,
      'p_seq': p_seq,
      'm_seq': m_seq,
      's_superseq': s_superseq,
    };
  }

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      req_seq: json['req_seq'] as int,
      created_at: json['created_at'] as String?,
      req_content: json['req_content'] as String?,
      req_quantity: json['req_quantity'] as int,
      req_manappdate: json['req_manappdate'] as String?,
      req_dirappdate: json['req_dirappdate'] as String?,
      s_seq: json['s_seq'] as int,
      p_seq: json['p_seq'] as int,
      m_seq: json['m_seq'] as int,
      s_superseq: json['s_superseq'] as int?,
    );
  }
}