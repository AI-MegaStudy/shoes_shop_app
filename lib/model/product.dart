class Product {
  final int? p_seq; // 고객 고유 ID(PK)
  int kc_seq;
  int cc_seq;
  int sc_seq;
  int gc_seq;
  final int m_seq;
  final String p_name;
  final int p_price;
  final int p_stock;
  final String p_image;
  final String p_description;
  final DateTime? created_at;
  String? p_color;
  String? p_size;
  String? p_gender;
  String? p_maker;

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
    this.p_color,
    this.p_size,
    this.p_gender,
    this.p_maker,
  });

  /// JSON으로 변환 (GetStorage 저장용)
  Map<String, dynamic> toJson() {
    return {
      "p_seq": p_seq,
      "kc_seq": kc_seq,
      "cc_seq": cc_seq,
      "sc_seq": sc_seq,
      "gc_seq": gc_seq,
      "m_seq": m_seq,
      "p_name": p_name,
      "p_price": p_price,
      "p_stock": p_stock,
      "p_image": p_image,
      "p_description": p_description,
      "created_at": created_at,
      "p_color": p_color,
      "p_size": p_size,
      "p_gender": p_gender,
      "p_maker": p_maker,
    };
  }

  /// JSON에서 생성
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      p_seq: json["p_seq"],
      kc_seq: json["kc_seq"],
      cc_seq: json["cc_seq"],
      sc_seq: json["sc_seq"],
      gc_seq: json["gc_seq"],
      m_seq: json["m_seq"],
      p_name: json["p_name"],
      p_price: json["p_price"],
      p_stock: json["p_stock"],
      p_image: json["p_image"],
      p_description: json["p_description"] != null ? json["p_description"] : '',
      created_at: DateTime.now(),
      p_color: json["p_color"],
      p_size: json["p_size"],
      p_gender: json["p_gender"],
      p_maker: json["p_maker"],
    );
  }
}
