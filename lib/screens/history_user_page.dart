import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
            doc.id,
            data['rating'] ?? 0.0,
            data['review'] ?? '',
          ];
        }).toList();
      });
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  void _showRatingDialog(BuildContext context, String orderId) {
    TextEditingController reviewController = TextEditingController();
    double rating = 0.0; // Giá trị mặc định cho rating

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Review',
            style: TextStyle(
              color: AppColors.backgroundOrange,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thay TextField bằng RatingBar
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                maxRating: 5,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              TextField(
                controller: reviewController,
                maxLines: 2, // Giới hạn số dòng tối đa là 5
                decoration: InputDecoration(
                  labelText: 'Review',
                  labelStyle: TextStyle(
                    color: AppColors.backgroundOrange,
                  ), // Đặt màu cho hintText
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.backgroundOrange,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Gọi hàm để cập nhật Firebase
                _updateReviewInFirebase(
                  orderId,
                  rating.toInt(), // Sử dụng rating từ RatingBar
                  reviewController.text,
                );
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: Text(
                'Submit',
                style: TextStyle(
                  color: AppColors.backgroundOrange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateReviewInFirebase(
      String orderId, int rating, String review) async {
    print(orderId);
    try {
      // Cập nhật đơn hàng với thông tin đánh giá
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'rating': rating,
        'review': review,
      });
      print('Review updated successfully!');
    } catch (e) {
      print('Error updating review: $e');
    }
    setState(() {
      fetchOrders();
    });
  }

  void _showReviewDialog(BuildContext context, String review) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Review',
            style: TextStyle(
              color: AppColors.backgroundOrange,
            ),
          ),
          content: Text(review),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppColors.backgroundOrange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
              padding: const EdgeInsets.all(15),
              height: 130,
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
                            Icons.account_circle,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(widget.buyer.userName.toUpperCase(),
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.phone_android, size: 20),
                          SizedBox(
                            width: 10,
                          ),
                          Text(widget.buyer.phone.toUpperCase(),
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 20),
                          SizedBox(
                            width: 10,
                          ),
                          Text(widget.buyer.email.toUpperCase(),
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 20),
                          SizedBox(
                            width: 10,
                          ),
                          Text(widget.buyer.address.toUpperCase(),
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15, left: 20, right: 20),
              child: Text(
                "All Orders",
                style: AppTypography.textMd
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            for (var item in card)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
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
                                const SizedBox(
                                  height: 5,
                                ),
                                item[6] == 0.0
                                    ? IconButton(
                                        onPressed: () {
                                          _showRatingDialog(context, item[5]);
                                        },
                                        icon: Icon(
                                          Icons.message,
                                          color: Colors
                                              .white, // Màu biểu tượng trắng
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: AppColors
                                              .backgroundOrange, // Màu nền cam
                                          shape:
                                              CircleBorder(), // Hình dạng nút là hình tròn
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          CircleAvatar(
                                            radius:
                                                15, // Điều chỉnh bán kính để phù hợp với kích thước icon
                                            backgroundColor:
                                                const Color(0xFFFFF2E0),
                                            child: IconButton(
                                              icon: Icon(Icons.comment,
                                                  size:
                                                      15, // Kích thước biểu tượng
                                                  color: Colors.grey),
                                              onPressed: () =>
                                                  _showReviewDialog(
                                                      context, item[7]),
                                            ),
                                          ),
                                          RatingBarIndicator(
                                            rating: item[6].toDouble(),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            itemCount: 5,
                                            itemSize: 20.0,
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
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
