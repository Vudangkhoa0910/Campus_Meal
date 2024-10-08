import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryPageUser extends StatefulWidget {
  Buyer buyer;
  HistoryPageUser({super.key, required this.buyer});

  @override
  State<HistoryPageUser> createState() => HistoryPageUserState();
}

class HistoryPageUserState extends State<HistoryPageUser> with RouteAware {
  List card = []; // Khởi tạo danh sách card rỗng

  void reloadData() {
    fetchOrders();
  }

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Gọi hàm lấy đơn hàng khi khởi tạo
  }

  Future<void> fetchOrders() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders') // Tên collection của bạn
          .where('buyer_name',
              isEqualTo: widget.buyer.userName) // Lọc theo tên buyer
          .get();

      setState(() {
        card = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return [
            data['shop_name'] ?? 'Unknown',
            data['order_name'] ?? 'Unknown',
            data['price']?.toString() ?? '0',
            data['date'] ?? 'Unknown',
            data['img'] ?? 'Unknown',
          ];
        }).toList();
      });
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(15),
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
                            Icons.account_circle,
                            size: 15,
                          ),
                          Text(widget.buyer.userName,
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.phone_android, size: 15),
                          Text(widget.buyer.phone,
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.email, size: 15),
                          Text(widget.buyer.email,
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 15),
                          Text(widget.buyer.address,
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "All Orders",
                style: AppTypography.textMd
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            for (var item in card)
              Container(
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
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Text("Shop : ${item[0]}",
                                      style: AppTypography.textSm
                                          .copyWith(fontSize: 14)),
                                ),
                                Text(
                                  "Order : ${item[1]}",
                                  style: AppTypography.textSm.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "Price : ${item[2]}",
                                  style: AppTypography.textSm.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                ),
                                // Text(
                                //   "Count : ${item[3]}",
                                //   style: AppTypography.textSm.copyWith(
                                //       fontSize: 14,
                                //       fontWeight: FontWeight.w400),
                                // ),
                                Text(
                                  "Time : ${item[3]}",
                                  style: AppTypography.textSm.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
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
                                    color: AppColors.backgroundOrange,
                                    width: 1.5),
                                borderRadius: BorderRadius.circular(20)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                item[4],
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
              )
          ],
        ),
      ),
    );
  }
}
