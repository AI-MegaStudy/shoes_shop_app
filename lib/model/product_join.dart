class ProductJoin {
  int? p_seq;
  String? p_name;
  int? p_price;
  int? p_stock;
  String? p_image;
  // String? p_description;
  // String? created_at;

  int? kc_seq;
  String? kc_name;
  int? qc_seq;
  String? qc_name;
  int? cc_seq;
  String? cc_name;
  int? sc_seq;
  String? sc_name;
  int? gc_seq;
  String? gc_name;

  int? m_seq;
  String? m_name;
  String? m_phone;
  String? m_address;

  ProductJoin({
    this.p_seq,
    this.p_name,
    this.p_price,
    this.p_stock,
    this.p_image,

    // this.p_description,
    // this.created_at,
    this.kc_seq,
    this.kc_name,
    this.qc_seq,
    this.qc_name,
    this.cc_seq,
    this.cc_name,
    this.sc_seq,
    this.sc_name,
    this.gc_seq,
    this.gc_name,

    this.m_seq,
    this.m_name,
    this.m_phone,
    this.m_address,
  });

  factory ProductJoin.fromJson(Map<String, dynamic> json) {
    return ProductJoin(
      p_seq: json['p_seq'] as int?,
      p_name: json['p_name'] as String?,
      p_price: json['p_price'] as int?,
      p_stock: json['p_stock'] as int?,
      p_image: json['p_image'] as String?,

      //p_description: json['p_description'] as String?,
      // created_at: json['created_at'] as String?,
      kc_seq: json['kc_seq'] as int?,
      kc_name: json['kc_name'] as String?,
      qc_seq: json['qc_seq'] as int?,
      qc_name: json['qc_name'] as String?,
      cc_seq: json['cc_seq'] as int?,
      cc_name: json['cc_name'] as String?,
      sc_seq: json['sc_seq'] as int?,
      sc_name: json['sc_name'] as String?,
      gc_seq: json['gc_seq'] as int?,
      gc_name: json['gc_name'] as String?,

      m_seq: json['m_seq'] as int?,
      m_name: json['m_name'] as String?,
      m_phone: json['m_phone'] as String?,
      m_address: json['m_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'p_seq': p_seq,
      'p_name': p_name,
      'p_price': p_price,
      'p_stock': p_stock,
      'p_image': p_image,
      //'p_description': p_description,
      //'created_at': created_at,
      'kc_seq': kc_seq,
      'kc_name': kc_name,
      'qc_seq': qc_seq,
      'qc_name': qc_name,
      'cc_seq': cc_seq,
      'cc_name': cc_name,
      'sc_seq': sc_seq,
      'sc_name': sc_name,
      'gc_seq': gc_seq,
      'gc_name': gc_name,
      'm_seq': m_seq,
      'm_name': m_name,
      'm_phone': m_phone,
      'm_address': m_address,
    };
  }
}
