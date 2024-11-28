import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:campus_catalogue/screens/Scanner/QRScannerOverlay.dart';
import 'package:campus_catalogue/screens/Scanner/foundScreen.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Scanner extends StatefulWidget {
  final ShopModel shop;
  const Scanner({Key? key, required this.shop}) : super(key: key);

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  @override
  void initState() {
    super.initState();
    _screenWasClosed(); // Đảm bảo _screenOpened là false khi khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
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
          "Scanner",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.backgroundOrange),
        ),
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect:
                _foundBarcode, // Chỉ cần truyền hàm `_foundBarcode` trực tiếp
          ),
          QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
        ],
      ),
    );
  }

  void _foundBarcode(BarcodeCapture barcodeCapture) {
    if (!_screenOpened) {
      _screenOpened = true; // Đánh dấu màn hình đã mở
      final String code = barcodeCapture.barcodes.first.rawValue ?? "___";

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoundScreen(
            value: code,
            screenClose: _screenWasClosed,
            shop: widget.shop,
          ),
        ),
      ).then((_) {
        _screenWasClosed();
      });
    }
  }

  void _screenWasClosed() {
    _screenOpened = false;
  }
}
