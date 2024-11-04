import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    controller =
        null; // Khởi tạo controller ở đây, sẽ gán giá trị trong callback
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController qrController) {
          setState(() {
            controller = qrController;
          });
          controller!.scannedDataStream.listen((scanData) {
            // Xử lý dữ liệu quét được
            print(scanData.code);
            Navigator.pop(context, scanData.code); // Đóng màn hình quét
          });
        },
      ),
    );
  }
}
