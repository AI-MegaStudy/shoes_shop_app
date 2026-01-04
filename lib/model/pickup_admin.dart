class PickupAdmin {
  final int? pic_seq;
  final String? created_at;
  final int? b_seq;
  final int? b_price;
  final int? b_quantity;
  final String? b_date;
  final String? b_status;
  final int? u_seq;
  final String? u_name;
  final String? u_phone;
  final String? u_email;
  final int? p_seq;
  final String? p_name;
  final int? p_price;
  final String? p_image;
  final String? kc_name;
  final String? cc_name;
  final String? sc_name;
  final String? gc_name;
  final String? m_name;
  final int? br_seq;
  final String? br_name;
  final String? br_address;
  final String? br_phone;

  PickupAdmin({
    this.pic_seq,
    this.created_at,
    this.b_seq,
    this.b_price,
    this.b_quantity,
    this.b_date,
    this.b_status,
    this.u_seq,
    this.u_name,
    this.u_phone,
    this.u_email,
    this.p_seq,
    this.p_name,
    this.p_price,
    this.p_image,
    this.kc_name,
    this.cc_name,
    this.sc_name,
    this.gc_name,
    this.m_name,
    this.br_seq,
    this.br_name,
    this.br_address,
    this.br_phone,
  });

  /// JSON 데이터에서 객체 생성
  factory PickupAdmin.fromJson(Map<String, dynamic> json) {
    return PickupAdmin(
      pic_seq: json['pic_seq'] as int?,
      created_at: json['created_at'] as String?,
      b_seq: json['b_seq'] as int?,
      b_price: json['b_price'] as int?,
      b_quantity: json['b_quantity'] as int?,
      b_date: json['b_date'] as String?,
      b_status: json['b_status'] as String?,
      u_seq: json['u_seq'] as int?,
      u_name: json['u_name'] as String?,
      u_phone: json['u_phone'] as String?,
      u_email: json['u_email'] as String?,
      p_seq: json['p_seq'] as int?,
      p_name: json['p_name'] as String?,
      p_price: json['p_price'] as int?,
      p_image: json['p_image'] as String?,
      kc_name: json['kc_name'] as String?,
      cc_name: json['cc_name'] as String?,
      sc_name: json['sc_name'] as String?,
      gc_name: json['gc_name'] as String?,
      m_name: json['m_name'] as String?,
      br_seq: json['br_seq'] as int?,
      br_name: json['br_name'] as String?,
      br_address: json['br_address'] as String?,
      br_phone: json['br_phone'] as String?,
    );
  }

  /// 객체를 JSON(Map)으로 변환
  Map<String, dynamic> toJson() {
    return {
      'pic_seq': pic_seq,
      'created_at': created_at,
      'b_seq': b_seq,
      'b_price': b_price,
      'b_quantity': b_quantity,
      'b_date': b_date,
      'b_status': b_status,
      'u_seq': u_seq,
      'u_name': u_name,
      'u_phone': u_phone,
      'u_email': u_email,
      'p_seq': p_seq,
      'p_name': p_name,
      'p_price': p_price,
      'p_image': p_image,
      'kc_name': kc_name,
      'cc_name': cc_name,
      'sc_name': sc_name,
      'gc_name': gc_name,
      'm_name': m_name,
      'br_seq': br_seq,
      'br_name': br_name,
      'br_address': br_address,
      'br_phone': br_phone,
    };
  }
}