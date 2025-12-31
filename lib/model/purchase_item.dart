class PurchaseItem {
  final int b_seq;
  final int br_seq;
  final int u_seq;
  final int p_seq;
  final int b_price;
  final int b_quantity;
  final String created_at;
  final String b_status;

  PurchaseItem({
    required this.b_seq,
    required this.br_seq,
    required this.u_seq,
    required this.p_seq,
    required this.b_price,
    required this.b_quantity,
    required this.created_at,
    required this.b_status,
  });

  Map<String, dynamic> toJson() {
    return {
      'b_seq': b_seq,
      'br_seq': br_seq,
      'u_seq': u_seq,
      'p_seq': p_seq,
      'b_price': b_price,
      'b_quantity': b_quantity,
      'created_at': created_at,
      'b_status': b_status,
    };
  }

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      b_seq: json['b_seq'] as int,
      br_seq: json['br_seq'] as int,
      u_seq: json['u_seq'] as int,
      p_seq: json['p_seq'] as int,
      b_price: json['b_price'] as int,
      b_quantity: json['b_quantity'] as int,
      created_at: json['created_at'] as String,
      b_status: json['b_status'] as String,
    );
  }
}