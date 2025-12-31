class Receive {
  final int rec_seq;
  final int rec_quantity;
  final String? created_at;
  final int s_seq;
  final int p_seq;
  final int m_seq;

  Receive({
    required this.rec_seq,
    required this.rec_quantity,
    this.created_at,
    required this.s_seq,
    required this.p_seq,
    required this.m_seq,
  });

  Map<String, dynamic> toJson() {
    return {
      'rec_seq': rec_seq,
      'rec_quantity': rec_quantity,
      'created_at': created_at,
      's_seq': s_seq,
      'p_seq': p_seq,
      'm_seq': m_seq,
    };
  }

  factory Receive.fromJson(Map<String, dynamic> json) {
    return Receive(
      rec_seq: json['rec_seq'] as int,
      rec_quantity: json['rec_quantity'] as int,
      created_at: json['created_at'] as String?,
      s_seq: json['s_seq'] as int,
      p_seq: json['p_seq'] as int,
      m_seq: json['m_seq'] as int,
    );
  }
}