import 'package:campus_catalogue/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRCodeScreen extends StatelessWidget {
  final String buyerId;

  QRCodeScreen({required this.buyerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
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
          style: TextStyle(color: AppColors.backgroundOrange, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _getQRCodeIds(),
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
                    side: BorderSide(color: Colors.orangeAccent, width: 3),
                  ),
                  color: const Color.fromARGB(255, 251, 243, 190),
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
      List<dynamic> qrCodeData = snapshot.data()?['qr_codes'] ?? [];

      return qrCodeData.map((item) {
        return {
          'id': item['id'] as String,
          'url': item['url'] as String,
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
          backgroundColor: AppColors.backgroundYellow,
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
                Image.network(
                  qrUrl,
                  height: 230.0,
                  width: 230.0,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
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
