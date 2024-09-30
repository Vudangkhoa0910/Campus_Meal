import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  String shopID;
  String upiId;
  String shopName;
  String shopType;
  String location;
  String openingTime;
  String closingTime;
  String ownerName;
  String phoneNumber;
  bool? status;
  String alternatePhoneNumber;
  List menu;
  Map<String, int> rating;
  String img;

  ShopModel(
      {required this.shopID,
      required this.alternatePhoneNumber,
      required this.closingTime,
      required this.location,
      required this.openingTime,
      required this.ownerName,
      required this.phoneNumber,
      required this.shopName,
      required this.shopType,
      required this.upiId,
      required this.menu,
      this.status,
      required this.rating,
      required this.img});

  Map<String, dynamic> toMap() {
    return {
      'shop_id': shopID,
      'upi_id': upiId,
      'shop_name': shopName,
      'shop_type': shopType,
      'location': location,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'owner_name': ownerName,
      'phone_number': phoneNumber,
      'alternate_phone_number': alternatePhoneNumber,
      'menu': menu,
      "rating": rating,
      "status": status,
      "img": img,
    };
  }

  ShopModel.fromMap(Map<String, dynamic> sellerMap)
      : shopID = sellerMap["shop_id"],
        shopName = sellerMap["shop_name"],
        upiId = sellerMap["upi_id"],
        shopType = sellerMap["shop_type"],
        location = sellerMap["location"],
        openingTime = sellerMap["opening_time"],
        closingTime = sellerMap["closing_time"],
        ownerName = sellerMap["owner_name"],
        phoneNumber = sellerMap["phone_number"],
        alternatePhoneNumber = sellerMap["alternate_phone_number"],
        menu = List.from(sellerMap["menu"]),
        rating = Map<String, int>.from(sellerMap["rating"] ?? {}),
        status = sellerMap["status"],
        img = sellerMap["img"];

  ShopModel.fromDocument(DocumentSnapshot doc)
      : shopID = doc["shop_id"],
        shopName = doc["shop_name"],
        upiId = doc["upi_id"],
        shopType = doc["shop_type"],
        location = doc["location"],
        openingTime = doc["opening_time"],
        closingTime = doc["closing_time"],
        ownerName = doc["owner_name"],
        phoneNumber = doc["phone_number"],
        alternatePhoneNumber = doc["alternate_phone_number"],
        menu = doc["menu"],
        rating = doc["rating"],
        status = doc["status"],
        img = doc["img"];
}
