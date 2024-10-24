import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/screens/cart.dart';
import 'package:campus_catalogue/screens/home_screen.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:core';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentInfo extends StatefulWidget {
  Buyer buyer;
  PaymentInfo({super.key, required this.buyer});

  @override
  State<PaymentInfo> createState() => _PaymentInfoState();
}

class _PaymentInfoState extends State<PaymentInfo> {
  // final List<String> dh = ["rice", "fish", "meat", "salad", "egg", "bread"];
  // final List<int> count = [2, 3, 4, 2, 4, 5];
  // final List<double> fee = [25.3, 24.6, 27.6, 28.9, 30, 10.5];
  double total = 0.0;

  List<Map<String, dynamic>> items = []; // Danh sách sản phẩm từ Firebase
  List<int> quantities = []; // Danh sách số lượng cho từng sản phẩm
  double totalPrice = 0;
  num discount = 1;

  @override
  void initState() {
    super.initState();
    _initRetrieval(); // Khởi tạo dữ liệu giỏ hàng
    getDiscount();
  }

  void _initRetrieval() async {
    final data = await DatabaseService()
        .getOrders(widget.buyer.userName); // Lấy dữ liệu từ Firebase

    for (var order in data) {
      items.add({
        'name': order['name'],
        'price': order['price'],
        'imgUrl': order['imgUrl'],
        'count': order['count'] // Lấy hình ảnh từ Firebase
      });
      quantities.add(1); // Mặc định là 1 cho mỗi sản phẩm
    }

    if (mounted) {
      setState(() {}); // Cập nhật trạng thái
    }
  }

  Future<void> getDiscount() async {
    // Lấy instance của FirebaseFirestore
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Lấy instance của FirebaseAuth
    FirebaseAuth _auth = FirebaseAuth.instance;

    // Lấy document từ Firestore
    QuerySnapshot querySnapshot = await _firestore
        .collection('buy')
        .where('buyer_name', isEqualTo: widget.buyer.userName)
        .get();

    // Lấy giá trị của 'discount' từ document
    if (querySnapshot.docs.isNotEmpty) {
      // Lấy DocumentSnapshot đầu tiên
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

      // Xử lý documentSnapshot
      print(documentSnapshot.data());
    } else {
      print('No documents found');
    }
  }

  Future<void> saveInvoice() async {
    try {
      final data = await DatabaseService()
          .getOrders(widget.buyer.userName); // Lấy dữ liệu từ Firebase
      // Duyệt qua từng sản phẩm trong danh sách
      for (var item in data) {
        await FirebaseFirestore.instance.collection('orders').add({
          'buyer_name': item['buyer_name'],
          'buyer_phone': item['buyer_phone'],
          'date': item['date'],
          'img': item['imgUrl'],
          'order_name': item['name'],
          'price': item['price'],
          'shop_name': item['shop_name'],
          'count': item['count']
        });
      }
      // Thông báo lưu thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hóa đơn đã được lưu thành công!')),
      );
    } catch (e) {
      // Xử lý lỗi nếu có
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu hóa đơn: $e')),
      );
    }
  }

  Future<void> deleteBuy() async {
    try {
      // Lấy các tài liệu có buyer_name bằng với widget.buyer.userName
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buy')
          .where('buyer_name', isEqualTo: widget.buyer.userName)
          .get();
// Xoá từng tài liệu trong kết quả truy vấn
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print("Xoá thành công");
    } catch (e) {
      print("Lỗi khi xoá: $e");
    }
  }

  // Phương thức tính tổng
  void calculateTotal() {
    // if (count.length != fee.length) {
    //   throw Exception('Hai danh sách count và fee phải có độ dài bằng nhau.');
    // }

    total = 0.0; // Đặt lại giá trị của total trước khi tính lại
    // for (int i = 0; i < items.length; i++) {
    //   total += items[i]['count'] * items[i]['price'];
    // }
    for (int i = 0; i < items.length; i++) {
      double itemPrice = items[i]['count'] * items[i]['price'];

      // Áp dụng discount
      double discountedPrice = itemPrice - (itemPrice * discount / 10);

      total += discountedPrice;
    }
  }

  @override
  Widget build(BuildContext context) {
    calculateTotal();

    // Khởi tạo ScreenUtil
    ScreenUtil.init(
      context,
      // designSize: const Size(360, 490), // Android
      designSize: const Size(250, 900), // Kích thước thiết kế mặc định
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(buyer: widget.buyer)));
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xffF57C51),
              ));
        }),
        title: const Text(
          "Pay",
          style: TextStyle(color: Color(0xffF57C51)),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 250.h,
            width: 350.w,
            child: Image.asset("assets/KhoaCyber.png"),
          ),
          Padding(
            padding: EdgeInsets.all(15.r),
            child: Container(
              height: 330.h,
              width: 280.w,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.5.w,
                  color: const Color(0xffF57C51),
                ),
                borderRadius: BorderRadius.all(Radius.circular(20.r)),
              ),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Container(
                      padding: EdgeInsets.all(5.r),
                      height: 100.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.5.w,
                          color: const Color(0xffF57C51),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20.r)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Displaying the image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                8.r), // Adding border radius
                            child: Image.network(
                              items[index]["imgUrl"],
                              width: 50.w,
                              height: 70.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Displaying the product name and price details
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    items[index]["name"],
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 20.sp, // Dynamic font
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    "Quantity : ${items[index]["count"]}",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    "Total : ${items[index]["price"]}",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: 200.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total : ",
                    style: TextStyle(
                      color: const Color(0xffF57C51),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    )),
                Text("$total",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ))
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              saveInvoice();
              setState(() {
                deleteBuy();
              });
            },
            child: Container(
              width: 200.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: const Color(0xffF57C51),
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
              ),
              child: Center(
                child: Text(
                  "Pay",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
