import 'package:campus_catalogue/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Buy {
  final String buyerName;
  List<OrderModel> orders;
  num discount;
  String id;

  Buy(
      {required this.buyerName,
      required this.orders,
      this.discount = 1,
      required this.id});

  Map<String, dynamic> toMap() {
    // Chuyển đổi danh sách orders thành danh sách map
    return {
      'buyer_name': buyerName,
      'orders': orders
          .map((order) => order.toMap())
          .toList(), // Đảm bảo gọi toMap cho từng order
      'id': id,
    };
  }

  Buy.fromMap(Map<String, dynamic> buyMap)
      : buyerName = buyMap["buyer_name"],
        orders = List<OrderModel>.from(
            buyMap["orders"].map((orderMap) => OrderModel.fromMap(orderMap))),
        discount = buyMap['discount'],
        id = buyMap['id']; // Sử dụng fromMap cho OrderModel

  Buy.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : buyerName = doc.data()!["buyer_name"],
        orders = List<OrderModel>.from(doc
            .data()!["orders"]
            .map((orderMap) => OrderModel.fromMap(orderMap))),
        discount = doc.data()!['discount'],
        id = doc.data()!['id']; // Cũng tương tự ở đây
}
