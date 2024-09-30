import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  String name;
  num price;
  String category;
  bool vegetarian;
  String description;
  String imgUrl;

  ItemModel(
      {required this.category,
      required this.description,
      required this.name,
      required this.price,
      required this.vegetarian,
      required this.imgUrl});

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'description': description,
      'name': name,
      'price': price,
      'vegetarian': vegetarian,
      'imgUrl': imgUrl
    };
  }

  ItemModel.fromMap(Map<String, dynamic> sellerMap)
      : category = sellerMap["category"],
        description = sellerMap["description"],
        name = sellerMap["name"],
        price = sellerMap["price"],
        vegetarian = sellerMap["vegetarian"],
        imgUrl = sellerMap["imgUrl"];

  ItemModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : name = doc.data()!["name"],
        description = doc.data()!["description"],
        category = doc.data()!["category"],
        price = doc.data()!["price"],
        vegetarian = doc.data()!["vegetarian"],
        imgUrl = doc.data()!["imgUrl"];
}
