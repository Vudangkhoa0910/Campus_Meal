// // import 'package:campus_catalogue/constants/colors.dart';
// // import 'package:flutter/material.dart';

// // class FoundScreen extends StatefulWidget {
// //   final String value;
// //   final Function() screenClose;
// //   const FoundScreen({Key? key, required this.value, required this.screenClose})
// //       : super(key: key);

// //   @override
// //   State<FoundScreen> createState() => _FoundScreenState();
// // }

// // class _FoundScreenState extends State<FoundScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         leading: Builder(
// //           builder: (BuildContext context) {
// //             return RotatedBox(
// //               quarterTurns: 0,
// //               child: IconButton(
// //                 icon: Icon(Icons.arrow_back_ios_new_rounded,
// //                     color: AppColors.backgroundOrange),
// //                 onPressed: () => Navigator.pop(context, false),
// //               ),
// //             );
// //           },
// //         ),
// //         title: Text("Result",
// //             style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.w600,
// //                 color: AppColors.backgroundOrange)),
// //         backgroundColor: AppColors.backgroundYellow,
// //       ),
// //       body: Center(
// //         child: Padding(
// //           padding: EdgeInsets.all(20),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Text(
// //                 "Result: ",
// //                 style: TextStyle(fontSize: 20),
// //               ),
// //               SizedBox(height: 20),
// //               Text(widget.value, style: TextStyle(fontSize: 16))
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:campus_catalogue/constants/colors.dart';

// class FoundScreen extends StatefulWidget {
//   final String value; // Raw QR data (in JSON string format)
//   final Function() screenClose;

//   const FoundScreen({
//     Key? key,
//     required this.value,
//     required this.screenClose,
//   }) : super(key: key);

//   @override
//   State<FoundScreen> createState() => _FoundScreenState();
// }

// class _FoundScreenState extends State<FoundScreen> {
//   late Map<String, dynamic> decodedData;

//   @override
//   void initState() {
//     super.initState();
//     decodedData =
//         jsonDecode(widget.value); // Decode QR data to get orders and order_id
//   }

//   @override
//   Widget build(BuildContext context) {
//     List orders = decodedData['orders'] ?? [];
//     // String orderId = decodedData['order_id'] ?? 'No Order ID';

//     return Scaffold(
//       appBar: AppBar(
//         leading: Builder(
//           builder: (BuildContext context) {
//             return RotatedBox(
//               quarterTurns: 0,
//               child: IconButton(
//                 icon: Icon(Icons.arrow_back_ios_new_rounded,
//                     color: AppColors.backgroundOrange),
//                 onPressed: () => Navigator.pop(context, false),
//               ),
//             );
//           },
//         ),
//         title: Text("Result",
//             style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.backgroundOrange)),
//         backgroundColor: AppColors.backgroundYellow,
//       ),
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Text(
//               //   "Order ID: $orderId",
//               //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               // ),
//               SizedBox(height: 20),
//               Text("Orders:", style: TextStyle(fontSize: 16)),
//               SizedBox(height: 10),
//               // Use ListView to display orders with images
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: orders.length,
//                   itemBuilder: (context, index) {
//                     final order = orders[index];
//                     final imgUrl = order['img'] ?? ''; // Get img URL from order
//                     return Card(
//                       margin: EdgeInsets.symmetric(vertical: 5),
//                       elevation: 4,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             imgUrl.isNotEmpty
//                                 ? Container(
//                                     width:
//                                         150, // Adjust width to make image larger
//                                     height:
//                                         150, // Adjust height to make image larger
//                                     child: Image.network(
//                                       imgUrl,
//                                       fit: BoxFit
//                                           .cover, // Ensure the image fits within the given space
//                                     ),
//                                   )
//                                 : SizedBox(), // Show image if available
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text("Name: ${order['order_name']}"),
//                                   SizedBox(height: 5),
//                                   Text("Count: ${order['count']}"),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: widget.screenClose,
//                 child: Text("Close"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.backgroundOrange,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:campus_catalogue/constants/colors.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FoundScreen extends StatefulWidget {
  final String value; // Raw QR data (in JSON string format)
  final Function()
      screenClose; // Function to close the screen and delete QR code

  const FoundScreen({
    Key? key,
    required this.value,
    required this.screenClose,
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

      final exists =
          await ref.getMetadata().then((_) => true).catchError((_) => false);

      if (exists) {
        await ref.delete();
        print("QR code image deleted from Storage successfully.");
      } else {
        print("QR code image does not exist in Storage.");
      }

      final docRef =
          FirebaseFirestore.instance.collection('qr_codes').doc(buyerId);
      DocumentSnapshot snapshot = await docRef.get();

      if (snapshot.exists) {
        List<dynamic> qrCodes = snapshot.get('qr_codes');
        List<dynamic> updatedQrCodes = qrCodes.where((qrCode) {
          return qrCode['id'] != qrCodeId;
        }).toList();

        await docRef.update({'qr_codes': updatedQrCodes});
        print("QR code data removed from Firestore successfully.");
      } else {
        print("Document does not exist in Firestore.");
      }
    } catch (e) {
      print("Error deleting QR code: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List orders = decodedData['orders'] ?? [];
    String buyerId = decodedData['buyer_id'] ?? '';
    String qrCodeId = decodedData['qr_code_id'] ?? '';

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
        title: Text("Order Details",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.backgroundOrange)),
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
                              "Name: ${order['order_name']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22, // Tăng cỡ chữ
                                fontFamily: 'Roboto', // Phông chữ đẹp
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Count: ${order['count']}",
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
                await deleteQRCode(buyerId, qrCodeId);
                widget.screenClose();
              },
              child: Text("Close", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundOrange,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                textStyle: TextStyle(fontSize: 18),
                elevation: 5, // Thêm hiệu ứng bóng cho nút
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Bo góc nút
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
