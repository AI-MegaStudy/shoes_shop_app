class KindCategory {
  int? kc_seq;
  String kc_name;

  KindCategory({
    this.kc_seq,
    required this.kc_name,
  });

  factory KindCategory.fromJson(Map<String, dynamic> json) {
    return KindCategory(
      kc_seq: json['kc_seq'],
      kc_name: json['kc_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kc_seq': kc_seq,
      'kc_name': kc_name,
    };
  }
}