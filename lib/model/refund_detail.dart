class RefundDetail {
  // Refund 기본 정보
  final int? ref_seq;
  final String? ref_date;
  final String? ref_reason;

  // User 정보
  final int? u_seq;
  final String? u_name;
  final String? u_phone;

  // Staff 정보
  final int? s_seq;
  final String? s_rank;
  final String? s_phone;

  // Photo(Pic) 정보
  final int? pic_seq;
  final String? created_at;

  // Purchase(Buy) 정보
  final int? b_seq;
  final int? b_price;
  final int? b_quantity;
  final String? b_date;

  // Product 정보 및 상세 카테고리
  final int? p_seq;
  final String? p_name;
  final int? p_price;
  final String? p_image;
  final String? kind_name;
  final String? color_name;
  final String? size_name;
  final String? gender_name;
  final String? maker_name;

  // Branch 정보
  final int? br_seq;
  final String? br_name;
  final String? br_address;

  RefundDetail({
    this.ref_seq,
    this.ref_date,
    this.ref_reason,
    this.u_seq,
    this.u_name,
    this.u_phone,
    this.s_seq,
    this.s_rank,
    this.s_phone,
    this.pic_seq,
    this.created_at,
    this.b_seq,
    this.b_price,
    this.b_quantity,
    this.b_date,
    this.p_seq,
    this.p_name,
    this.p_price,
    this.p_image,
    this.kind_name,
    this.color_name,
    this.size_name,
    this.gender_name,
    this.maker_name,
    this.br_seq,
    this.br_name,
    this.br_address,
  });

  /// JSON 데이터에서 객체 생성
  factory RefundDetail.fromJson(Map<String, dynamic> json) {
    return RefundDetail(
      ref_seq: json['ref_seq'] as int?,
      ref_date: json['ref_date'] as String?,
      ref_reason: json['ref_reason'] as String?,
      u_seq: json['u_seq'] as int?,
      u_name: json['u_name'] as String?,
      u_phone: json['u_phone'] as String?,
      s_seq: json['s_seq'] as int?,
      s_rank: json['s_rank'] as String?,
      s_phone: json['s_phone'] as String?,
      pic_seq: json['pic_seq'] as int?,
      created_at: json['created_at'] as String?,
      b_seq: json['b_seq'] as int?,
      b_price: json['b_price'] as int?,
      b_quantity: json['b_quantity'] as int?,
      b_date: json['b_date'] as String?,
      p_seq: json['p_seq'] as int?,
      p_name: json['p_name'] as String?,
      p_price: json['p_price'] as int?,
      p_image: json['p_image'] as String?,
      kind_name: json['kind_name'] as String?,
      color_name: json['color_name'] as String?,
      size_name: json['size_name'] as String?,
      gender_name: json['gender_name'] as String?,
      maker_name: json['maker_name'] as String?,
      br_seq: json['br_seq'] as int?,
      br_name: json['br_name'] as String?,
      br_address: json['br_address'] as String?,
    );
  }

  /// 객체를 JSON(Map)으로 변환
  Map<String, dynamic> toJson() {
    return {
      'ref_seq': ref_seq,
      'ref_date': ref_date,
      'ref_reason': ref_reason,
      'u_seq': u_seq,
      'u_name': u_name,
      'u_phone': u_phone,
      's_seq': s_seq,
      's_rank': s_rank,
      's_phone': s_phone,
      'pic_seq': pic_seq,
      'created_at': created_at,
      'b_seq': b_seq,
      'b_price': b_price,
      'b_quantity': b_quantity,
      'b_date': b_date,
      'p_seq': p_seq,
      'p_name': p_name,
      'p_price': p_price,
      'p_image': p_image,
      'kind_name': kind_name,
      'color_name': color_name,
      'size_name': size_name,
      'gender_name': gender_name,
      'maker_name': maker_name,
      'br_seq': br_seq,
      'br_name': br_name,
      'br_address': br_address,
    };
  }
}