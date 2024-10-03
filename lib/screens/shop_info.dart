import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buy_model.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/models/item_model.dart';
import 'package:campus_catalogue/models/order_model.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String shopName;
  final String name;
  final num price;
  final String description;
  final bool vegetarian;
  final String img;
  final Buyer buyer;

  const ItemCard({
    super.key,
    required this.shopName,
    required this.name,
    required this.price,
    required this.description,
    required this.vegetarian,
    required this.img,
    required this.buyer,
  });

  Future<void> addOrder(String buyerPhone, String buyerName, String shopName,
      num price, String date, String orderName, String img) async {
    CollectionReference orders =
        FirebaseFirestore.instance.collection('orders');

    // num x = orders.

    return orders.add({
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
    }).then((value) {
      print("Order Added");
    }).catchError((error) {
      print("Failed to add order: $error");
    });
  }

  // Future<void> addBuy(String buyerName, List<OrderModel> orders) async {
  //   CollectionReference buy = FirebaseFirestore.instance.collection('buy');

  //   // Tạo một đối tượng Buy và thêm nó vào Firestore
  //   Buy newBuy = Buy(buyerName: buyerName, orders: orders);

  //   return buy.add(newBuy.toMap()).then((value) {
  //     print("Buy Added");
  //   }).catchError((error) {
  //     print("Failed to add buy: $error");
  //   });
  // }
  Future<void> addBuy(String buyerName, List<OrderModel> orders) async {
    CollectionReference buy = FirebaseFirestore.instance.collection('buy');

    // Lấy dữ liệu cũ từ Firestore
    QuerySnapshot existingBuys = await buy.get();

    // Kiểm tra xem các trường trong orders đã tồn tại hay chưa
    bool exists = false;
    for (var doc in existingBuys.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Kiểm tra từng order trong danh sách orders
      List<dynamic> existingOrders =
          data['orders']; // Giả sử 'orders' là một danh sách
      for (var order in orders) {
        // Duyệt qua từng order trong existingOrders để kiểm tra trùng lặp
        for (var existingOrder in existingOrders) {
          if (existingOrder['buyer_name'] == order.buyerName &&
              existingOrder['shop_name'] == order.shopName &&
              existingOrder['order_name'] == order.orderName) {
            exists = true;
            break; // Dừng vòng lặp nếu tìm thấy trùng lặp
          }
        }
        if (exists) break; // Dừng nếu đã tìm thấy trùng lặp
      }
      if (exists) break; // Dừng nếu đã tìm thấy trùng lặp
    }

    // Nếu không có trùng lặp, thêm tài liệu mới vào Firestore
    if (!exists) {
      Buy newBuy = Buy(buyerName: buyerName, orders: orders);
      return buy.add(newBuy.toMap()).then((value) {
        print("Buy Added");
      }).catchError((error) {
        print("Failed to add buy: $error");
      });
    } else {
      print("Buy with the same order already exists. Not added.");
    }
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
      child: Container(
          decoration: BoxDecoration(
              color: const Color(0xFFFFF2E0),
              borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  // Sửa để tránh lỗi overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (vegetarian)
                      //   Text(
                      //     "VEG",
                      //     style: AppTypography.textSm.copyWith(
                      //         color: Color.fromARGB(255, 0, 196, 0),
                      //         fontSize: 14),
                      //   )
                      // else
                      // Text("NON VEG",
                      //     style: AppTypography.textSm.copyWith(
                      //         color: Color.fromARGB(255, 197, 0, 0),
                      //         fontSize: 14)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Text("Price: ${price}",
                            style: AppTypography.textSm.copyWith(fontSize: 14)),
                      ),
                      Text(
                        "Name: ${name}",
                        style: AppTypography.textMd.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "Description: ${description}",
                        style: AppTypography.textSm.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      GestureDetector(
                        onTap: () {
                          addBuy(
                            buyer.userName,
                            [
                              // Thay đổi ở đây để truyền danh sách các OrderModel
                              OrderModel(
                                buyerPhone: buyer.phone,
                                buyerName: buyer.userName,
                                shopName: shopName,
                                count: 1,
                                price: price,
                                date: formatDate(DateTime.now()),
                                orderName: name,
                                img: img,
                              ),
                            ],
                          );
                          // addOrder(buyer.phone, buyer.userName, shopName, price,
                          //     formatDate(DateTime.now()), name, img);
                        },
                        child: Container(
                          width: 200,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(238, 118, 0, 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Center(
                            child: Text(
                              "ADD ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.backgroundOrange, width: 1.5),
                      borderRadius: BorderRadius.circular(20)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/iconshop.jpg', // Đường dẫn đến hình ảnh thay thế
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class ShopPage extends StatefulWidget {
  final ShopModel? shop;
  // final String shopName;

  final String name;
  final String rating;
  final String location;
  final List menu;
  final String ownerName;
  final String upiID;
  final Buyer buyer;
  const ShopPage({
    super.key,
    this.shop,
    // required this.shopName,

    required this.name,
    required this.rating,
    required this.location,
    required this.menu,
    required this.ownerName,
    required this.upiID,
    required this.buyer,
  });

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  Widget build(BuildContext context) {
    print(widget.menu);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundYellow,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.backgroundOrange,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        centerTitle: true,
        title: Text(widget.name,
            style: AppTypography.textMd.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.backgroundOrange)),
      ),
      backgroundColor: AppColors.backgroundYellow,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              height: 120,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pin_drop_rounded,
                            size: 15,
                          ),
                          Text(widget.location,
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.timelapse_rounded, size: 15),
                          Text("9 AM TO 10 PM",
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.shopping_cart, size: 15),
                          Text("${widget.menu.length} ITEMS AVAILABLE",
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Container(
                          width: 30,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.signIn),
                          child: Row(
                            children: [
                              Text(
                                widget
                                    .rating, // Thay giá trị cố định bằng rating từ widget
                                style: AppTypography.textSm.copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const Icon(
                                Icons.star,
                                size: 15,
                              )
                            ],
                          ))
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "All Items",
                style: AppTypography.textMd
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            for (var item in widget.menu)
              ItemCard(
                shopName: widget.name,
                // shopName: widget.shop?.shopName ??
                //     'Unknown Shop', // Provide a fallback
                name: item["name"] ?? 'Unknown',
                price: item["price"] ?? 0.0,
                description: item["description"] ?? 'No description',
                vegetarian: item["veg"] ?? false,
                img: item["img"],
                buyer: widget.buyer,
              ),
          ],
        ),
      ),
    );
  }
}
