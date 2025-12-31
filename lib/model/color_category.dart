class ColorCategory {
  int? cc_seq;
  String cc_name;

  ColorCategory({
    this.cc_seq,
    required this.cc_name,
  });

  factory ColorCategory.fromJson(Map<String, dynamic> json) {
    return ColorCategory(
      cc_seq: json['cc_seq'],
      cc_name: json['cc_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cc_seq': cc_seq,
      'cc_name': cc_name,
    };
  }
}