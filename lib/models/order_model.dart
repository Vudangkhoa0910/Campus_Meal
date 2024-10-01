import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String buyerPhone;
  String buyerName;
  // String txnId;
  String shopName;
  // String status;
  // num totalAmount;
  num price;
  String date;
  String orderName;
  String img;
  // List items;

  OrderModel(
      {required this.buyerPhone,
      required this.buyerName,
      // required this.txnId,
      required this.shopName,
      // required this.status,
      // required this.totalAmount,
      required this.price,
      required this.date,
      required this.orderName,
      required this.img
      // required this.items
      });

  Map<String, dynamic> toMap() {
    return {
      'buyer_phone': buyerPhone,
      'buyer_name': buyerName,
      // 'txn_id': txnId,
      'shop_name': shopName,
      // 'status': status,
      // 'total_amount': totalAmount,
      'price': price,
      'date': date,
      'order_name': orderName,
      'img': img,
      // 'items': items
    };
  }

  OrderModel.fromMap(Map<String, dynamic> sellerMap)
      : buyerPhone = sellerMap["buyer_phone"],
        buyerName = sellerMap["buyer_name"],
        // txnId = sellerMap["txn_id"],
        shopName = sellerMap["shop_name"],
        // status = sellerMap["status"],
        // totalAmount = sellerMap["total_amount"],
        price = sellerMap["price"],
        date = sellerMap["date"],
        orderName = sellerMap["order_name"],
        img = sellerMap["img"];
  // items = sellerMap["items"];

  OrderModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : buyerPhone = doc.data()!["buyer_phone"],
        buyerName = doc.data()!["buyerName"],
        // txnId = doc.data()!['txn_id'],
        shopName = doc.data()!["shop_name"],
        // status = doc.data()!['status'],
        // totalAmount = doc.data()!['total_amount'],
        price = doc.data()!['price'],
        date = doc.data()!['date'],
        orderName = doc.data()!['order_name'],
        img = doc.data()!['img'];
  // items = doc.data()!["items"];
}
