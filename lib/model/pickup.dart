class Pickup {
  int? pic_seq;
  int b_seq;
  int u_seq;
  String? created_at;

  Pickup({
    this.pic_seq,
    required this.b_seq,
    required this.u_seq,
    this.created_at,
  });

  factory Pickup.fromJson(Map<String, dynamic> json) {
    return Pickup(
      pic_seq: json['pic_seq'],
      b_seq: json['b_seq'],
      u_seq: json['u_seq'],
      created_at: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pic_seq': pic_seq,
      'b_seq': b_seq,
      'u_seq': u_seq,
      'created_at': created_at,
    };
  }
}