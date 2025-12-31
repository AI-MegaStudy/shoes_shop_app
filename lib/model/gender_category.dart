class GenderCategory {
  int? gc_seq;
  String gc_name;

  GenderCategory({
    this.gc_seq,
    required this.gc_name,
  });

  factory GenderCategory.fromJson(Map<String, dynamic> json) {
    return GenderCategory(
      gc_seq: json['gc_seq'],
      gc_name: json['gc_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gc_seq': gc_seq,
      'gc_name': gc_name,
    };
  }
}