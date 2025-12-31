class Product {
  final int? pSeq;           // 고객 고유 ID(PK)
  final int kcSeq;
  final int ccSeq;
  final int scSeq;
  final int gcseq;
  final int mSeq;
  final String pName;
  final int pPrice;
  final int pStock;
  final String pImage;
  final String pDescription;
  final DateTime? created_at;
  final String? ccSeqColor;
  final String? scSeqSize;
  final String? gcSeqGender;
  final String? mSeqName;


  Product({
    this.pSeq,           
    required this.kcSeq,
    required this.ccSeq,
    required this.scSeq,
    required this.gcseq,
    required this.mSeq,
    required this.pName,
    required this.pPrice,
    required this.pStock,
    required this.pImage,
    required this.pDescription,
    this.created_at,
    this.ccSeqColor,
    this.scSeqSize,
    this.gcSeqGender,
    this.mSeqName
  });
  
  /// JSON으로 변환 (GetStorage 저장용)
  Map<String, dynamic> toJson() {
    return {
      "pSeq":pSeq,           
      "kcSeq":kcSeq,
      "ccSeq":ccSeq,
      "scSeq":scSeq,
      "gcseq":gcseq,
      "mSeq":mSeq,
      "pName":pName,
      "pPrice":pPrice,
      "pStock":pStock,
      "pImage":pImage,
      "pDescription":pDescription,
      "created_at":created_at
    };
  }
  
  /// JSON에서 생성
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      pSeq:json["p_eq"],           
      kcSeq:json["kc_seq"],
      ccSeq:json["cc_seq"],
      scSeq:json["sc_seq"],
      gcseq:json["gc_seq"],
      mSeq:json["m_seq"],
      pName:json["p_name"],
      pPrice:json["p_price"],
      pStock:json["p_stock"],
      pImage:json["p_image"],
      pDescription:json["p_description"] != null ? json["p_description"] : '' ,
      created_at: DateTime.parse(json["created_at"].toString())
      // ccSeqColor:json["ccSeqcolor"],
      // scSeqSize:json["scSeqSize"],
      // gcSeqGender:json["gcSeqGender"],
      // mSeqName:json["mSeqName"]
    );
  }
}

