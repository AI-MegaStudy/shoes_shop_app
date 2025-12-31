class Maker {
  int? m_seq;
  String m_phone;
  String m_name;
  String m_address;

  Maker({
    this.m_seq,
    required this.m_phone,
    required this.m_name,
    required this.m_address,
  });

  factory Maker.fromJson(Map<String, dynamic> json) {
    return Maker(
      m_seq: json['m_seq'],
      m_phone: json['m_phone'],
      m_name: json['m_name'],
      m_address: json['m_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'm_seq': m_seq,
      'm_phone': m_phone,
      'm_name': m_name,
      'm_address': m_address,
    };
  }
}