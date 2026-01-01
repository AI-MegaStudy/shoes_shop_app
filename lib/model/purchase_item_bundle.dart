import 'package:shoes_shop_app/model/purchase_item_join.dart';

class PurchaseItemBundle {
  String? order_datetime;
  String? order_time;
  int? branch_seq;
  String? branch_name;
  int? item_count;
  int? total_amount;
  List<PurchaseItemJoin>? items;

  PurchaseItemBundle({
    this.order_datetime,
    this.order_time,
    this.branch_seq,
    this.branch_name,
    this.item_count,
    this.total_amount,
    this.items,
  });

  factory PurchaseItemBundle.fromJson(Map<String, dynamic> json) {
    return PurchaseItemBundle(
      order_datetime: json['order_datetime'],
      order_time: json['order_time'],
      branch_seq: json['branch_seq'],
      branch_name: json['branch_name'],
      item_count: json['item_count'],
      total_amount: json['total_amount'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => PurchaseItemJoin.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_datetime': order_datetime,
      'order_time': order_time,
      'branch_seq': branch_seq,
      'branch_name': branch_name,
      'item_count': item_count,
      'total_amount': total_amount,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }
}