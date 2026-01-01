import 'package:shoes_shop_app/model/purchase_item_join.dart';

class PurchaseItemBundle {
  String? order_date;
  String? order_time;
  int? item_count;
  int? total_amount;
  List<PurchaseItemJoin>? items;

  PurchaseItemBundle({
    this.order_date,
    this.order_time,
    this.item_count,
    this.total_amount,
    this.items,
  });

  factory PurchaseItemBundle.fromJson(Map<String, dynamic> json) {
    return PurchaseItemBundle(
      order_date: json['order_date'],
      order_time: json['order_time'],
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
      'order_date': order_date,
      'order_time': order_time,
      'item_count': item_count,
      'total_amount': total_amount,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }
}