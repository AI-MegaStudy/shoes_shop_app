class PurchaseItemJoin {
  int? b_seq;
  int? b_price;
  int? b_quantity;
  String? b_date;
  String? b_status;

  int? u_seq;
  String? u_email;
  String? u_name;
  String? u_phone;

  int? p_seq;
  String? p_name;
  int? p_price;
  int? p_stock;
  String? p_image;

  String? kc_name;
  String? cc_name;
  String? sc_name;
  String? gc_name;
  String? m_name;

  int? br_seq;
  String? br_name;
  String? br_address;
  String? br_phone;

  PurchaseItemJoin({
    this.b_seq,
    this.b_price,
    this.b_quantity,
    this.b_date,
    this.b_status,
    this.u_seq,
    this.u_email,
    this.u_name,
    this.u_phone,
    this.p_seq,
    this.p_name,
    this.p_price,
    this.p_stock,
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

  factory PurchaseItemJoin.fromJson(Map<String, dynamic> json) {
    return PurchaseItemJoin(
      b_seq: json['b_seq'],
      b_price: json['b_price'],
      b_quantity: json['b_quantity'],
      b_date: json['b_date'],
      b_status: json['b_status'],
      u_seq: json['u_seq'],
      u_email: json['u_email'],
      u_name: json['u_name'],
      u_phone: json['u_phone'],
      p_seq: json['p_seq'],
      p_name: json['p_name'],
      p_price: json['p_price'],
      p_stock: json['p_stock'],
      p_image: json['p_image'],
      kc_name: json['kc_name'],
      cc_name: json['cc_name'],
      sc_name: json['sc_name'],
      gc_name: json['gc_name'],
      m_name: json['m_name'],
      br_seq: json['br_seq'],
      br_name: json['br_name'],
      br_address: json['br_address'],
      br_phone: json['br_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'b_seq': b_seq,
      'b_price': b_price,
      'b_quantity': b_quantity,
      'b_date': b_date,
      'b_status': b_status,
      'u_seq': u_seq,
      'u_email': u_email,
      'u_name': u_name,
      'u_phone': u_phone,
      'p_seq': p_seq,
      'p_name': p_name,
      'p_price': p_price,
      'p_stock': p_stock,
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