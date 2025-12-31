class Branch {
  int? br_seq;
  String br_phone;
  String br_address;
  String br_name;
  double br_lat;
  double br_lng;

  Branch({
    this.br_seq,
    required this.br_phone,
    required this.br_address,
    required this.br_name,
    required this.br_lat,
    required this.br_lng
  });

  factory Branch.fromJson(Map<String, dynamic> json){
    return Branch(
      br_seq: json['br_seq'],
      br_phone: json['br_phone'], 
      br_address: json['br_address'], 
      br_name: json['br_name'], 
      br_lat: json['br_lat'], 
      br_lng: json['br_lng']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'br_seq': br_seq,
      'br_phone': br_phone,
      'br_address': br_address,
      'br_name': br_name,
      'br_lat': br_lat,
      'br_lng': br_lng
    };
  }
}