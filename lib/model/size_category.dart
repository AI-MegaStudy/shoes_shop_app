class SizeCategory {
  final int sc_seq;
  final String sc_name;

  SizeCategory({required this.sc_seq, required this.sc_name});

  Map<String, dynamic> toJson() {
    return {'sc_seq': sc_seq, 'sc_name': sc_name};
  }

  factory SizeCategory.fromJson(Map<String, dynamic> json) {
    return SizeCategory(sc_seq: json['sc_seq'] as int, sc_name: json['sc_name'] as String);
  }
}
