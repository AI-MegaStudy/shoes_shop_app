class RefundJoin {
  // refund
  int? ref_seq;
  String? ref_date;
  int? ref_re_content;

  // refund reason
  int? ref_re_seq;
  String? ref_re_name;

  // user
  int? u_seq;
  String? u_email;
  String? u_name;
  String? u_phone;

  // staff
  int? s_seq;
  String? s_name;
  String? s_rank;
  String? s_phone;

  // pickup
  int? pic_seq;
  String? pic_created_at;

  // purchase_item
  int? b_seq;
  int? b_price;
  int? b_quantity;
  String? b_date;
  String? b_status;

  // product
  int? p_seq;
  String? p_name;
  int? p_price;
  int? p_stock;
  String? p_image;

  // category / maker
  String? kc_name;
  String? cc_name;
  String? sc_name;
  String? gc_name;
  String? m_name;

  // branch
  int? br_seq;
  String? br_name;
  String? br_address;
  String? br_phone;

  RefundJoin({
    this.ref_seq,
    this.ref_date,
    this.ref_re_content,
    this.ref_re_seq,
    this.ref_re_name,
    this.u_seq,
    this.u_email,
    this.u_name,
    this.u_phone,
    this.s_seq,
    this.s_name,
    this.s_rank,
    this.s_phone,
    this.pic_seq,
    this.pic_created_at,
    this.b_seq,
    this.b_price,
    this.b_quantity,
    this.b_date,
    this.b_status,
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

  factory RefundJoin.fromJson(Map<String, dynamic> json) {
    return RefundJoin(
      ref_seq: json['ref_seq'],
      ref_date: json['ref_date'],
      ref_re_content: json['ref_re_content'],

      ref_re_seq: json['ref_re_seq'],
      ref_re_name: json['ref_re_name'],

      u_seq: json['u_seq'],
      u_email: json['u_email'],
      u_name: json['u_name'],
      u_phone: json['u_phone'],

      s_seq: json['s_seq'],
      s_name: json['s_name'],
      s_rank: json['s_rank'],
      s_phone: json['s_phone'],

      pic_seq: json['pic_seq'],
      pic_created_at: json['pic_created_at'],

      b_seq: json['b_seq'],
      b_price: json['b_price'],
      b_quantity: json['b_quantity'],
      b_date: json['b_date'],
      b_status: json['b_status'],

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
      'ref_seq': ref_seq,
      'ref_date': ref_date,
      'ref_re_content': ref_re_content,

      'ref_re_seq': ref_re_seq,
      'ref_re_name': ref_re_name,

      'u_seq': u_seq,
      'u_email': u_email,
      'u_name': u_name,
      'u_phone': u_phone,

      's_seq': s_seq,
      's_name': s_name,
      's_rank': s_rank,
      's_phone': s_phone,

      'pic_seq': pic_seq,
      'pic_created_at': pic_created_at,

      'b_seq': b_seq,
      'b_price': b_price,
      'b_quantity': b_quantity,
      'b_date': b_date,
      'b_status': b_status,

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