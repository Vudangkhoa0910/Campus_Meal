import 'package:campus_catalogue/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRCodeScreen extends StatelessWidget {
  final String buyerId;

  QRCodeScreen({required this.buyerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.backgroundOrange,
          ),
        ),
        backgroundColor: AppColors.backgroundYellow,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'QR Codes',
          style: TextStyle(color: AppColors.backgroundOrange),
        ),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _getQRCodeIds(), // Fetch list of QR codes with IDs and URLs
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load QR codes.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No QR codes available.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          } else {
            final qrCodes = snapshot.data!;
            return ListView.builder(
              itemCount: qrCodes.length,
              itemBuilder: (context, index) {
                final qrCode = qrCodes[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading:
                        Icon(Icons.qr_code, color: AppColors.backgroundOrange),
                    title: Text(
                      'QR Code ID: ${qrCode['id']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Tap to view QR code'),
                    onTap: () => _showQRCodeDialog(context, qrCode['url']!),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, String>>> _getQRCodeIds() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('qr_codes')
        .doc(buyerId)
        .get();

    if (snapshot.exists) {
      // Truy xuất mảng qr_codes từ Firestore
      List<dynamic> qrCodeData = snapshot.data()?['qr_codes'] ?? [];

      // Trả về danh sách các map chứa 'id' và 'url'
      return qrCodeData.map((item) {
        return {
          'id': item['id'] as String,
          'url': item['url'] as String, // Thêm trường url
        };
      }).toList();
    } else {
      return [];
    }
  }

  void _showQRCodeDialog(BuildContext context, String qrUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QR Code',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                CachedNetworkImage(
                  imageUrl: qrUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error, color: Colors.red),
                  height: 300.0,
                  width: 300.0,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.backgroundOrange,
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
