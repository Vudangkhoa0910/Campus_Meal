import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/screens/cart.dart';
import 'package:campus_catalogue/screens/home_screen.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:core';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  // void _initRetrieval() async {
  //   final data = await DatabaseService()
  //       .getOrders(widget.buyer.userName); // Lấy dữ liệu từ Firebase

  //   for (var order in data) {
  //     items.add({
  //       'name': order['name'],
  //       'price': order['price'],
  //       'imgUrl': order['imgUrl'],
  //       'count': order['count'] // Lấy hình ảnh từ Firebase
  //     });
  //     quantities.add(1); // Mặc định là 1 cho mỗi sản phẩm
  //   }

  //   if (mounted) {
  //     setState(() {}); // Cập nhật trạng thái
  //   }
  // }
  void _initRetrieval() {
    // Lắng nghe Stream từ getOrders và cập nhật items khi có dữ liệu mới
    DatabaseService().getOrders(widget.buyer.userName).listen((data) {
      items.clear(); // Xóa danh sách cũ để cập nhật lại với dữ liệu mới
      quantities.clear(); // Xóa danh sách số lượng cũ

      for (var order in data) {
        items.add({
          'name': order['name'],
          'price': order['price'],
          'imgUrl': order['imgUrl'],
          'count': order['count'],
        });
        quantities.add(1); // Mặc định số lượng là 1 cho mỗi sản phẩm
      }

      // Cập nhật giao diện sau khi thay đổi dữ liệu
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> getDiscount() async {
    // Lấy instance của FirebaseFirestore
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Lấy document từ Firestore
    QuerySnapshot querySnapshot = await _firestore
        .collection('buy')
        .where('buyer_name', isEqualTo: widget.buyer.userName)
        .get();

    // Kiểm tra nếu có tài liệu nào trong querySnapshot
    if (querySnapshot.docs.isNotEmpty) {
      // Lấy DocumentSnapshot đầu tiên
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

      // Lấy dữ liệu từ documentSnapshot
      final data = documentSnapshot.data() as Map<String, dynamic>?;

      // Kiểm tra dữ liệu và lấy giá trị 'discount'
      if (data != null && data.containsKey('discount')) {
        discount = data['discount'] ??
            1; // Cập nhật giá trị discount, mặc định là 0 nếu không tìm thấy
        print('Discount value: $discount');
      } else {
        // Nếu không tìm thấy discount trong dữ liệu
        discount = 1; // Đặt discount về 0
        print('Discount not found in the document. Setting discount to 0.');
      }
    } else {
      // Nếu không có tài liệu nào được tìm thấy
      discount = 1; // Đặt discount về 0
      print('No documents found. Setting discount to 0.');
    }
  }

  // Future<void> saveInvoice() async {
  //   try {
  //     final data = await DatabaseService()
  //         .getOrders(widget.buyer.userName); // Lấy dữ liệu từ Firebase
  //     // Duyệt qua từng sản phẩm trong danh sách
  //     for (var item in data) {
  //       await FirebaseFirestore.instance.collection('orders').add({
  //         'buyer_name': item['buyer_name'],
  //         'buyer_phone': item['buyer_phone'],
  //         'date': item['date'],
  //         'img': item['imgUrl'],
  //         'order_name': item['name'],
  //         'price': item['price'],
  //         'shop_name': item['shop_name'],
  //         'count': item['count'],
  //         'rating': 0.0,
  //       });
  //     }
  //     // Thông báo lưu thành công
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Hóa đơn đã được lưu thành công!')),
  //     );
  //   } catch (e) {
  //     // Xử lý lỗi nếu có
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Lỗi khi lưu hóa đơn: $e')),
  //     );
  //   }
  // }

  Future<void> saveInvoice() async {
    try {
      // Truy vấn trực tiếp từ Firestore collection 'buy' theo 'buyer_name'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('buy')
          .where('buyer_name', isEqualTo: widget.buyer.userName)
          .get();

      // Duyệt qua các tài liệu và xử lý từng đơn hàng bên trong 'orders'
      for (var buyDoc in snapshot.docs) {
        List<dynamic> ordersList = buyDoc['orders'];

        for (var order in ordersList) {
          // Lưu thông tin vào collection 'orders'
          // final String randomId = Uuid().v4(); // Tạo ID ngẫu nhiên

          await FirebaseFirestore.instance.collection('orders').add({
            'id': buyDoc['id'], // Thêm ID ngẫu nhiên
            'buyer_name': order['buyer_name'],
            'buyer_phone': order['buyer_phone'],
            'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
            'img': order['img'],
            'order_name': order['order_name'],
            'price': order['price'],
            'shop_name': order['shop_name'],
            'count': order['count'],
            'rating': 0.0,
            'pay': false,
          });

          // // Sau khi lưu đơn hàng, tạo mã QR cho từng đơn hàng
          // await generateAndUploadQRCode(
          //     [order]); // Gọi hàm tạo mã QR và upload lên Firebase
        }
      }

      // Hiển thị thông báo lưu thành công
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hóa đơn đã được lưu thành công!')),
        );
      }
    } catch (e) {
      // Xử lý lỗi và hiển thị thông báo lỗi
      print(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu hóa đơn: $e')),
        );
      }
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
    double discountedPrice = 0;
    for (int i = 0; i < items.length; i++) {
      double itemPrice = items[i]['count'] * items[i]['price'];

      if (discount == 1) {
        discountedPrice = itemPrice;
      } else {
        // Áp dụng discount
        discountedPrice = itemPrice - (itemPrice * discount / 100);
      }

      total += discountedPrice; // Cộng giá trị đã tính vào total
    }
  }

  Future<void> generateAndUploadQRCode() async {
    try {
      List<Map<String, dynamic>> orderList =
          []; // Khởi tạo orderList ngoài vòng lặp

      var uuid = Uuid();
      String qrCodeId = uuid.v4();

      // Lấy dữ liệu từ Firestore theo điều kiện
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('buy')
          .where('buyer_name', isEqualTo: widget.buyer.userName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Duyệt qua tất cả các tài liệu trong collection 'buy'
        for (var buyDoc in snapshot.docs) {
          List<dynamic> ordersList =
              buyDoc['orders']; // Lấy danh sách các đơn hàng

          // Tạo danh sách đơn hàng với các trường cần thiết
          for (var order in ordersList) {
            orderList.add({
              'shop_name': order['shop_name'],
              'order_name': order['order_name'], // Tên đơn hàng
              'count': order['count'], // Số lượng mặt hàng
              'img': order['img'], // Đường dẫn hình ảnh (nếu có)
              'id': buyDoc['id'],
            });
          }
        }

        // Dữ liệu JSON chứa danh sách các đơn hàng
        String qrData = jsonEncode({
          'orders': orderList, // Danh sách đơn hàng đầy đủ
          'buyer_id': widget.buyer.user_id, // ID của người mua
          'qr_code_id': qrCodeId,
        });

        // Tạo mã QR từ chuỗi JSON
        final qrPainter = QrPainter(
          data: qrData,
          version: QrVersions
              .auto, // Tự động điều chỉnh phiên bản để có kích thước QR tối ưu
          gapless: true,
        );

        // Kích thước mã QR (đảm bảo mã QR đủ lớn để chứa tất cả dữ liệu)
        final qrSize = 400.0; // Tăng kích thước mã QR để dễ dàng quét

        // Vẽ mã QR dưới dạng hình ảnh PNG
        final pictureRecorder = ui.PictureRecorder();
        final canvas = Canvas(pictureRecorder);
        final paint = Paint()..color = Colors.white;
        canvas.drawRect(Rect.fromLTWH(0, 0, qrSize, qrSize), paint);
        qrPainter.paint(canvas, Size(qrSize, qrSize));
        final img = await pictureRecorder
            .endRecording()
            .toImage(qrSize.toInt(), qrSize.toInt());
        final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        // Lưu mã QR vào tệp tạm thời
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$qrCodeId.png');
        await file.writeAsBytes(pngBytes);

        // Tải lên mã QR lên Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('qr_code/${widget.buyer.user_id}/$qrCodeId.png');

        final uploadTask = storageRef.putFile(
          file,
          SettableMetadata(contentType: 'image/png'),
        );

        await uploadTask.whenComplete(() async {
          String qrCodeUrl = await storageRef.getDownloadURL();

          // Lấy dữ liệu qr_codes hiện tại từ Firestore để giữ lại phần tử cũ
          DocumentSnapshot qrCodesDoc = await FirebaseFirestore.instance
              .collection('qr_codes')
              .doc(widget.buyer.user_id)
              .get();

          List<Map<String, dynamic>> existingQrCodes = [];

          if (qrCodesDoc.exists) {
            // Nếu đã có tài liệu, lấy dữ liệu cũ
            existingQrCodes =
                List<Map<String, dynamic>>.from(qrCodesDoc['qr_codes'] ?? []);
            print('QR : $existingQrCodes');
          }

          // Thêm QR code mới vào danh sách cũ
          existingQrCodes.add({
            'id': qrCodeId, // ID QR
            'url': qrCodeUrl, // Đường dẫn đến ảnh QR
          });
          print('QR : $existingQrCodes');

          // Cập nhật lại dữ liệu với mảng qr_codes mới
          await FirebaseFirestore.instance
              .collection('qr_codes')
              .doc(widget.buyer.user_id)
              .set(
                  {
                'qr_codes': existingQrCodes, // Cập nhật lại mảng qr_codes
              },
                  SetOptions(
                      merge:
                          true)); // Sử dụng merge để tránh ghi đè tài liệu cũ

          print(
              "QR code uploaded successfully to qr_code/${widget.buyer.user_id}");
        });
      } else {
        print("No orders found for this buyer.");
      }
    } catch (e) {
      print("Error generating or uploading QR code: $e");
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          // SizedBox(
          //   height: 250.h,
          //   width: 350.w,
          //   child: Image.asset("assets/KhoaCyber.png"),
          // ),
          Padding(
            padding: EdgeInsets.all(10.r),
            child: Container(
              margin: EdgeInsets.all(20),
              height: 500.h,
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
                      height: 150.h,
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
                              width: 70.w,
                              height: 100.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Displaying the product name and price details
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(15),
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
                                  // SizedBox(height: 5),
                                  Text(
                                    "Quantity : ${items[index]["count"]}",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  // SizedBox(height: 5),
                                  Text(
                                    "Total : ${items[index]["price"]}",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 20.sp,
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
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                    )),
                Text("$total",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                    ))
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                saveInvoice();
                generateAndUploadQRCode();
                deleteBuy();
              });

              // Hiển thị dialog sau khi nhấn Pay
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Không cho phép tắt khi bấm ra ngoài
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.amber[100],
                    title: const Center(
                      child: Text(
                        "Please Payment",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xffF57C51),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    content: SizedBox(
                      height: 450.h,
                      width: 350.w,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset("assets/KhoaCyber.png"),
                          const SizedBox(height: 20),
                          const Text(
                            "Processing...",
                            style: TextStyle(
                              color: Color(0xffF57C51),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const CircularProgressIndicator(
                            color: Color(0xffF57C51),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              // Sau 5 giây hiển thị dialog "Payment Successful"
              Future.delayed(const Duration(seconds: 5), () {
                Navigator.of(context).pop(); // Đóng dialog "processing"

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.amber[100],
                      title: const Text(
                        "Payment Successful",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xffF57C51),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: SizedBox(
                        height: 400.h,
                        width: 350.w,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset("assets/KhoaCyber.png"),
                            const SizedBox(height: 20),
                            const Text(
                              "Thank you for your payment!",
                              style: TextStyle(
                                color: Color(0xffF57C51),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              });
            },
            child: Container(
              width: 200.w,
              height: 90.h,
              decoration: BoxDecoration(
                color: const Color(0xffF57C51),
                borderRadius: BorderRadius.all(Radius.circular(10.r)),
              ),
              child: Center(
                child: Text(
                  "Pay",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
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
