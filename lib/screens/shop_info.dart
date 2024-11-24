import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buy_model.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/models/item_model.dart';
import 'package:campus_catalogue/models/order_model.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ItemCard extends StatefulWidget {
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

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
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
  bool _isEditable = false;

  bool _isUpdating = false;

  String _updateMessage = '';

  bool _showMessage = false;

  Future<void> addBuy(String buyerName, List<OrderModel> orders) async {
    setState(() {
      _isUpdating = true;
      _updateMessage = '';
      _showMessage = false;
    });
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
      final String randomId = Uuid().v4();
      Buy newBuy = Buy(buyerName: buyerName, orders: orders, id: randomId);
      return buy.add(newBuy.toMap()).then((value)
          // buy
          //     .doc(FirebaseAuth.instance.currentUser!.uid)
          //     .set(newBuy.toMap())
          //     .then((value) {
          {
        setState(() {
          _updateMessage = 'Buy successfully!';
          _isEditable = false;
          _showMessage = true;
        });
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            _showMessage = false; // Ẩn thông báo
          });
        });
        print("Buy Added");
      }).catchError((error) {
        print("Failed to add buy: $error");
      });
    } else {
      print("Buy with the same order already exists. Not added.");
      setState(() {
        _updateMessage = "Error: Buy already exists";
        _showMessage = true;
      });
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          _showMessage = false; // Ẩn thông báo
        });
      });
    }
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2E0),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Price: ${widget.price}",
                      style: AppTypography.textSm.copyWith(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Name: ${widget.name}",
                      style: AppTypography.textMd.copyWith(
                        fontSize: 14,
                        // fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Description: ${widget.description}",
                      style: AppTypography.textSm.copyWith(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        addBuy(
                          widget.buyer.userName,
                          [
                            OrderModel(
                              buyerPhone: widget.buyer.phone,
                              buyerName: widget.buyer.userName,
                              shopName: widget.shopName,
                              count: 1,
                              price: widget.price,
                              date: formatDate(DateTime.now()),
                              orderName: widget.name,
                              img: widget.img,
                            ),
                          ],
                        );
                      },
                      child: Container(
                        width: 200,
                        height: 35,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(238, 118, 0, 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            "ADD",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_showMessage && _updateMessage.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _updateMessage.contains('Error')
                              ? Colors.redAccent
                              : Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _updateMessage,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.backgroundOrange,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.img,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/iconshop.jpg',
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
        ),
      ),
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
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              height: 120,
              decoration: BoxDecoration(
                  border:
                      Border.all(color: AppColors.backgroundOrange, width: 2),
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
                          const Icon(
                            Icons.pin_drop_rounded,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(widget.location,
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timelapse_rounded, size: 20),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              "${widget.shop?.openingTime?.isNotEmpty == true ? widget.shop!.openingTime : '9'} AM TO ${widget.shop?.closingTime?.isNotEmpty == true ? widget.shop!.closingTime : '10'} PM",
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.shopping_cart, size: 20),
                          SizedBox(
                            width: 10,
                          ),
                          Text("${widget.menu.length} ITEMS AVAILABLE",
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      // Container(
                      //     width: 30,
                      //     padding: const EdgeInsets.all(2),
                      //     decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(5),
                      //         color: AppColors.signIn),
                      //     child: Row(
                      //       children: [
                      //         Text(
                      //           widget
                      //               .rating, // Thay giá trị cố định bằng rating từ widget
                      //           style: AppTypography.textSm.copyWith(
                      //               fontSize: 15, fontWeight: FontWeight.w700),
                      //         ),
                      //         const Icon(
                      //           Icons.star,
                      //           size: 15,
                      //         )
                      //       ],
                      //     ))
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
