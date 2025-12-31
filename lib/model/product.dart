class Product {
  int? p_seq;
  int kc_seq;
  int cc_seq;
  int sc_seq;
  int gc_seq;
  int m_seq;
  String p_name;
  int p_price;
  int p_stock;
  String p_image;
  String p_description;
  String? created_at;

  Product({
    this.p_seq,
    required this.kc_seq,
    required this.cc_seq,
    required this.sc_seq,
    required this.gc_seq,
    required this.m_seq,
    required this.p_name,
    required this.p_price,
    required this.p_stock,
    required this.p_image,
    required this.p_description,
    this.created_at,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      p_seq: json['p_seq'],
      kc_seq: json['kc_seq'],
      cc_seq: json['cc_seq'],
      sc_seq: json['sc_seq'],
      gc_seq: json['gc_seq'],
      m_seq: json['m_seq'],
      p_name: json['p_name'],
      p_price: json['p_price'],
      p_stock: json['p_stock'],
      p_image: json['p_image'],
      p_description: json['p_description'],
      created_at: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'p_seq': p_seq,
      'kc_seq': kc_seq,
      'cc_seq': cc_seq,
      'sc_seq': sc_seq,
      'gc_seq': gc_seq,
      'm_seq': m_seq,
      'p_name': p_name,
      'p_price': p_price,
      'p_stock': p_stock,
      'p_image': p_image,
      'p_description': p_description,
      'created_at': created_at,
    };
  }
}