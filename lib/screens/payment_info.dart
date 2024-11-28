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
  final List<Map<String, dynamic>> selectedOrders;

  PaymentInfo({
    Key? key,
    required this.buyer,
    required this.selectedOrders,
  }) : super(key: key);

  @override
  State<PaymentInfo> createState() => _PaymentInfoState();
}

class _PaymentInfoState extends State<PaymentInfo> {
  double total = 0.0;

  List<Map<String, dynamic>> items = []; 
  List<int> quantities = []; 
  double totalPrice = 0;
  num discount = 1;

 @override
  void initState() {
    super.initState();
    items = widget.selectedOrders; 
    quantities = List<int>.filled(items.length, 1); 
    calculateTotal();
    getDiscount();
  }

void calculateTotal() {
  total = 0.0; // Reset the total before recalculating.
  double discountedPrice = 0;
  for (int i = 0; i < widget.selectedOrders.length; i++) {
    double itemPrice = widget.selectedOrders[i]['count'] * widget.selectedOrders[i]['price'];

    if (discount == 1) {
      discountedPrice = itemPrice;
    } else {
      // Apply discount
      discountedPrice = itemPrice - (itemPrice * discount / 100);
    }

    total += discountedPrice; // Add the calculated price to the total
  }
}


  void _initRetrieval() {
    DatabaseService().getOrders(widget.buyer.userName).listen((data) {
      items.clear(); 
      quantities.clear(); 

      for (var order in data) {
        items.add({
          'shop_name': order['shop_name'],
          'name': order['name'],
          'price': order['price'],
          'imgUrl': order['imgUrl'],
          'count': order['count'],
        });
        quantities.add(1); 
      }

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

  Future<void> saveInvoice() async {
  try {
    List<Map<String, dynamic>> selectedOrders = widget.selectedOrders;

    // Tạo một order_id duy nhất cho đơn hàng này
    var uuid = Uuid();
    String orderId = uuid.v4(); // Tạo ID duy nhất cho đơn hàng

    // Tạo danh sách các mặt hàng trong đơn hàng
    List<Map<String, dynamic>> orderItems = selectedOrders.map((order) {
      return {
        'order_name': order['name'],
        'price': order['price'],
        'imgUrl': order['imgUrl'],
        'count': order['count'],
        'shop_name': order['shop_name'],
      };
    }).toList();

    // Lưu thông tin đơn hàng vào Firestore
    await FirebaseFirestore.instance.collection('orders').add({
      'order_id': orderId,  // ID duy nhất của đơn hàng
      'buyer_name': widget.buyer.userName,
      'buyer_phone': widget.buyer.phone,
      'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
      'total_price': total,  // Tổng giá trị của đơn hàng
      'discount': discount,  // Giảm giá áp dụng cho đơn hàng
      'status': 'pending',   // Trạng thái đơn hàng (chưa xử lý)
      'items': orderItems,   // Danh sách các mặt hàng trong đơn
      'pay': true,           // Đánh dấu là đã thanh toán
    });

    // Hiển thị thông báo lưu thành công
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hóa đơn đã được lưu thành công!')),
      );
    }

    // Sau khi lưu, có thể thông báo về đơn hàng cho bên bán hoặc xử lý khác ở đây

  } catch (e) {
    print("Error while saving invoice: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu hóa đơn: $e')),
      );
    }
  }
}



//   Future<void> deleteBuy() async {
//     try {
//       // Lấy các tài liệu có buyer_name bằng với widget.buyer.userName
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('buy')
//           .where('buyer_name', isEqualTo: widget.buyer.userName)
//           .get();
// // Xoá từng tài liệu trong kết quả truy vấn
//       for (var doc in querySnapshot.docs) {
//         await doc.reference.delete();
//       }

//       print("Xoá thành công");
//     } catch (e) {
//       print("Lỗi khi xoá: $e");
//     }
//   }

Future<void> updatePayStatus() async {
  try {
    for (var order in widget.selectedOrders) {
      String orderName = order['name'];
      
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buy')
          .where('buyer_name', isEqualTo: widget.buyer.userName)
          .where('pay', isEqualTo: false)  
          .get(); 

      for (var doc in querySnapshot.docs) {
        List orders = doc['orders'];

        for (var i = 0; i < orders.length; i++) {
          var orderItem = orders[i];

          if (orderItem['order_name'] == orderName) {
            await doc.reference.update({
              'pay': true, 
            });

            print("Đã cập nhật trạng thái thanh toán cho đơn hàng: $orderName");
            break; 
          }
          deleteBuy();
        }
      }
    }

    print("Đã cập nhật trạng thái thanh toán cho các đơn đã chọn.");
  } catch (e) {
    print("Lỗi khi cập nhật trạng thái thanh toán: $e");
  }
}

Future<void> deleteBuy() async {
  try {
    QuerySnapshot buySnapshot = await FirebaseFirestore.instance
        .collection('buy')
        .where('buyer_name', isEqualTo: widget.buyer.userName) 
        .get();

    bool hasDeletedItems = false; 

    for (var doc in buySnapshot.docs) {
      bool isPaid = doc['pay'] ?? false;  

      if (isPaid) {
        await doc.reference.delete();
        print("Đã xóa mặt hàng đã thanh toán: ${doc['orders']}");
        hasDeletedItems = true;
      }
    }

    if (!hasDeletedItems) {
      print("Không có mặt hàng nào đã thanh toán để xóa.");
    } else {
      print("Đã xóa các mặt hàng đã thanh toán");
    }

  } catch (e) {
    print("Lỗi khi xóa mặt hàng đã thanh toán: $e");
  }
}

  // // Phương thức tính tổng
  // void calculateTotal() {
  //   total = 0.0; // Đặt lại giá trị của total trước khi tính lại
  //   double discountedPrice = 0;
  //   for (int i = 0; i < items.length; i++) {
  //     double itemPrice = items[i]['count'] * items[i]['price'];

  //     if (discount == 1) {
  //       discountedPrice = itemPrice;
  //     } else {
  //       // Áp dụng discount
  //       discountedPrice = itemPrice - (itemPrice * discount / 100);
  //     }

  //     total += discountedPrice; // Cộng giá trị đã tính vào total
  //   }
  // }

  Future<void> generateAndUploadQRCode() async {
  try {
    List<Map<String, dynamic>> selectedOrders = widget.selectedOrders;
    var uuid = Uuid();
    String qrCodeId = uuid.v4();

    // Tạo danh sách đơn hàng đã chọn
    List<Map<String, dynamic>> orderList = selectedOrders.map((order) {
      return {
        'order_name': order['name'],
        'count': order['count'],
        'img': order['imgUrl'],
        'id': qrCodeId,
      };
    }).toList();

    // Dữ liệu JSON chứa danh sách các đơn hàng đã chọn
    String qrData = jsonEncode({
      'orders': orderList,
      'buyer_id': widget.buyer.user_id,
      'qr_code_id': qrCodeId,
    });

    // Tạo mã QR
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
    );
    final qrSize = 400.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, qrSize, qrSize), paint);
    qrPainter.paint(canvas, Size(qrSize, qrSize));
    final img = await pictureRecorder.endRecording().toImage(qrSize.toInt(), qrSize.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Lưu mã QR vào Firebase Storage
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$qrCodeId.png');
    await file.writeAsBytes(pngBytes);
    final storageRef = FirebaseStorage.instance.ref().child('qr_code/${widget.buyer.user_id}/$qrCodeId.png');
    final uploadTask = storageRef.putFile(file, SettableMetadata(contentType: 'image/png'));
    await uploadTask.whenComplete(() async {
      String qrCodeUrl = await storageRef.getDownloadURL();

      // Lấy dữ liệu qr_codes hiện tại từ Firestore để giữ lại phần tử cũ
      DocumentSnapshot qrCodesDoc = await FirebaseFirestore.instance.collection('qr_codes').doc(widget.buyer.user_id).get();
      List<Map<String, dynamic>> existingQrCodes = [];
      if (qrCodesDoc.exists) {
        existingQrCodes = List<Map<String, dynamic>>.from(qrCodesDoc['qr_codes'] ?? []);
      }

      // Thêm QR code mới vào danh sách cũ
      existingQrCodes.add({
        'id': qrCodeId,
        'url': qrCodeUrl,
      });

      // Cập nhật lại mảng qr_codes
      await FirebaseFirestore.instance.collection('qr_codes').doc(widget.buyer.user_id).set({
        'qr_codes': existingQrCodes,
      }, SetOptions(merge: true));

      print("QR code uploaded successfully.");
    });
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
            onTap: () async {
              setState(() {
                saveInvoice();
                generateAndUploadQRCode();
                updatePayStatus();
                deleteBuy();
              });
              // Hiển thị thông báo thanh toán thành công
              showDialog(
                context: context,
                barrierDismissible: false,
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
