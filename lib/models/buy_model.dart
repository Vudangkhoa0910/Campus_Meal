import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String buyerPhone;
  final String buyerName;
  final String shopName;
  final num count;
  final num price;
  final String date;
  final String orderName;
  final String img;
  final double rating;
  final String review;
  final bool pay;

  OrderModel({
    required this.buyerPhone,
    required this.buyerName,
    required this.shopName,
    required this.count,
    required this.price,
    required this.date,
    required this.orderName,
    required this.img,
    this.rating = 0.0,
    this.review = '',
    this.pay = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'buyer_phone': buyerPhone,
      'buyer_name': buyerName,
      'shop_name': shopName,
      'count': count,
      'price': price,
      'date': date,
      'order_name': orderName,
      'img': img,
      'rating': rating,
      'review': review,
    };
  }

  OrderModel.fromMap(Map<String, dynamic> map)
      : buyerPhone = map["buyer_phone"] ?? '',
        buyerName = map["buyer_name"] ?? '',
        shopName = map["shop_name"] ?? '',
        count = map["count"] ?? 0,
        price = map["price"] ?? 0,
        date = map["date"] ?? '',
        orderName = map["order_name"] ?? '',
        img = map["img"] ?? '',
        rating = (map["rating"] ?? 0).toDouble(),
        review = map["review"] ?? '',
        pay = map["pay"];

  OrderModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : buyerPhone = doc.data()?["buyer_phone"] ?? '',
        buyerName = doc.data()?["buyer_name"] ?? '',
        shopName = doc.data()?["shop_name"] ?? '',
        count = doc.data()?["count"] ?? 0,
        price = doc.data()?["price"] ?? 0,
        date = doc.data()?["date"] ?? '',
        orderName = doc.data()?["order_name"] ?? '',
        img = doc.data()?["img"] ?? '',
        rating = (doc.data()?["rating"] ?? 0).toDouble(),
        review = doc.data()?["review"] ?? '',
        pay = doc.data()?["pay"];
}
