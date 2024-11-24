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

  Future<void> changePay(String id) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('id', isEqualTo: id)
          .get();
      print("Changing payment status for order with ID: $id");

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.update({'pay': true});
      }
      print("Payment status updated successfully.");
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use null-aware operators to handle possible null values
    List orders = decodedData['orders'] ?? [];
    String buyerId = decodedData['buyer_id'] ?? '';
    String qrCodeId = decodedData['qr_code_id'] ?? '';
    String id = ''; // Default value for id

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
                  id = order['id'] ?? ''; // Ensure default value for id
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
                changePay(id);
                await deleteQRCode(buyerId, qrCodeId);
                widget.screenClose();
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
