import 'dart:convert';
import 'dart:io';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campus_catalogue/constants/colors.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;

class FoundScreen extends StatefulWidget {
  final ShopModel shop;
  final String value; // Raw QR data (in JSON string format)
  final Function()
      screenClose; // Function to close the screen and delete QR code

  const FoundScreen({
    Key? key,
    required this.value,
    required this.screenClose,
    required this.shop,
  }) : super(key: key);

  @override
  State<FoundScreen> createState() => _FoundScreenState();
}

class _FoundScreenState extends State<FoundScreen> {
  late Map<String, dynamic> decodedData;

  @override
  void initState() {
    super.initState();
    decodedData =
        jsonDecode(widget.value); // Decode QR data to get orders and order_id
  }

// Hàm xóa ảnh QR từ Firebase Storage
  Future<void> deleteQRCode(String buyerId, String qrCodeId) async {
    try {
      final qrImagePath = 'qr_code/$buyerId/$qrCodeId.png';
      print("Deleting QR image at: $qrImagePath");

      final ref = FirebaseStorage.instance.ref().child(qrImagePath);

      // Check if the image exists in Firebase Storage
      final exists =
          await ref.getMetadata().then((_) => true).catchError((_) => false);

      if (exists) {
        await ref.delete();
        print("QR code image deleted from Storage successfully.");
      } else {
        print("QR code image does not exist in Storage.");
      }

      // Remove QR code data from Firestore
      final docRef =
          FirebaseFirestore.instance.collection('qr_codes').doc(buyerId);
      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        List<dynamic> qrCodes = snapshot.get('qr_codes') ?? [];
        List<dynamic> updatedQrCodes = qrCodes.where((qrCode) {
          return qrCode['id'] != qrCodeId;
        }).toList();

        await docRef.update({'qr_codes': updatedQrCodes});
        print("QR code data removed from Firestore successfully.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Success!")),
        );
      } else {
        print("Document does not exist in Firestore.");
      }
    } catch (e) {
      print("Error deleting QR code: $e");
    }
  }

  // Future<void> changePay(List<String> id) async {
  //   try {
  //     QuerySnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('orders')
  //         .where('id', isEqualTo: id)
  //         .get();
  //     print("Changing payment status for order with ID: $id");

  //     for (QueryDocumentSnapshot doc in snapshot.docs) {
  //       await doc.reference.update({'pay': true});
  //     }
  //     print("Payment status updated successfully.");
  //   } catch (e) {
  //     print('Error updating payment status: $e');
  //   }
  // }

  Future<void> changePay(List<String> ids) async {
    try {
      // Truy vấn các đơn hàng có ID nằm trong danh sách ids
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('id', whereIn: ids)
          .get();

      print("Changing payment status for orders with IDs: $ids");

      // Duyệt qua các tài liệu và cập nhật trạng thái thanh toán
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.update({'pay': true});
      }

      print("Payment status updated successfully for all orders.");
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }

  Future<void> generateAndUploadQRCode(
      List<Map<String, dynamic>> remainingOrders,
      String buyerId,
      String qrCodeId) async {
    try {
      // var uuid = Uuid();
      // String qrCodeId = uuid.v4();

      // Tạo danh sách đơn hàng với các trường cần thiết từ remainingOrders
      List<Map<String, dynamic>> orderList = remainingOrders
          .map((order) => {
                'shop_name': order['shop_name'],
                'order_name': order['order_name'], // Tên đơn hàng
                'count': order['count'], // Số lượng mặt hàng
                'img': order['img'], // Đường dẫn hình ảnh (nếu có)
                'id': order['id'],
              })
          .toList();

      // Dữ liệu JSON chứa danh sách các đơn hàng
      String qrData = jsonEncode({
        'orders': orderList, // Danh sách đơn hàng còn lại
        'buyer_id': buyerId, // ID của người mua
        'qr_code_id': qrCodeId,
      });

      // Tạo mã QR từ chuỗi JSON
      final qrPainter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: true,
      );

      // Kích thước mã QR
      final qrSize = 400.0;

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

      // Tải mã QR lên Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('qr_code/${buyerId}/$qrCodeId.png');

      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/png'),
      );

      await uploadTask.whenComplete(() async {
        String qrCodeUrl = await storageRef.getDownloadURL();

        // Lấy dữ liệu qr_codes hiện tại từ Firestore để giữ lại phần tử cũ
        DocumentSnapshot qrCodesDoc = await FirebaseFirestore.instance
            .collection('qr_codes')
            .doc(buyerId)
            .get();

        List<Map<String, dynamic>> existingQrCodes = [];

        if (qrCodesDoc.exists) {
          existingQrCodes =
              List<Map<String, dynamic>>.from(qrCodesDoc['qr_codes'] ?? []);
        }

        // Thêm QR code mới vào danh sách cũ
        existingQrCodes.add({
          'id': qrCodeId,
          'url': qrCodeUrl,
        });

        // Cập nhật lại dữ liệu với mảng qr_codes mới
        await FirebaseFirestore.instance
            .collection('qr_codes')
            .doc(buyerId)
            .set({
          'qr_codes': existingQrCodes,
        }, SetOptions(merge: true));

        print("QR code uploaded successfully to qr_code/${buyerId}");
      });
    } catch (e) {
      print("Error generating or uploading QR code: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List remainingOrders = (decodedData['orders'] ?? [])
        .where((order) => order['shop_name'] != widget.shop.shopName)
        .toList();

    // Use null-aware operators to handle possible null values
    List orders = (decodedData['orders'] ?? [])
        .where((order) => order['shop_name'] == widget.shop.shopName)
        .toList();
    String buyerId = decodedData['buyer_id'] ?? '';
    String qrCodeId = decodedData['qr_code_id'] ?? '';

    List<String> id = []; // Default value for id

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return RotatedBox(
              quarterTurns: 0,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.backgroundOrange),
                onPressed: () => Navigator.pop(context, false),
              ),
            );
          },
        ),
        title: Text(
          "Order Details",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.backgroundOrange),
        ),
        backgroundColor: AppColors.backgroundYellow,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              "Orders",
              style: TextStyle(
                  fontSize: 24,
                  color: AppColors.backgroundOrange,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final imgUrl = order['img'] ?? ''; // Get img URL from order
                  if (order['id'] != null &&
                      order['id'].toString().isNotEmpty) {
                    id.add(order['id']);
                  }
                  return Container(
                    height: 220,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      image: imgUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(imgUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        color:
                            Colors.black.withOpacity(0.5), // Background overlay
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name: ${order['order_name'] ?? 'N/A'}", // Provide fallback for null
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Count: ${order['count'] ?? 0}", // Fallback for null
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await changePay(id);
                  await deleteQRCode(buyerId, qrCodeId);
                  if (remainingOrders != null && remainingOrders.isNotEmpty) {
                    // Ép kiểu từ List<dynamic> sang List<Map<String, dynamic>>
                    List<Map<String, dynamic>> validOrders =
                        List<Map<String, dynamic>>.from(remainingOrders);

                    await generateAndUploadQRCode(
                        validOrders, buyerId, qrCodeId);
                  } else {
                    print("No remaining orders to generate QR code.");
                  }
                  widget.screenClose();
                } catch (e) {
                  print("Error: $e");
                  // Hiển thị thông báo lỗi nếu cần
                }
              },
              child: Text("Delete",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundOrange,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle: TextStyle(fontSize: 18),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
