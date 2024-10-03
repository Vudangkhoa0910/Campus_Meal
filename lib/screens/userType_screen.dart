import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:campus_catalogue/screens/login.dart';
import 'package:campus_catalogue/screens/userInformation/buyer_details.dart';
import 'package:campus_catalogue/screens/userInformation/seller_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Add Firebase Authentication

import 'home_screen.dart'; // Assuming HomeScreen for Buyer
import 'seller_home_screen.dart'; // Assuming SellerHomeScreen for Seller

class UserType extends StatefulWidget {
  const UserType({Key? key}) : super(key: key);

  @override
  _UserTypeState createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to check if user is a Buyer or Seller
  Future<void> checkUserType(String type) async {
    final User? user = _auth.currentUser;

    if (user != null) {
      final uid = user.uid;

      if (type == "Buyer") {
        QuerySnapshot buyerQuery = await _firestore
            .collection("Buyer")
            .where("user_id", isEqualTo: uid)
            .get();

        if (buyerQuery.docs.isNotEmpty) {
          // Navigate to HomeScreen
          final Buyer buyer =
              Buyer.fromMap(buyerQuery.docs[0].data() as Map<String, dynamic>);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(buyer: buyer)),
          );
        } else {
          // Navigate to BuyerDetails
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BuyerDetails()),
          );
        }
      } else if (type == "Seller") {
        QuerySnapshot sellerQuery = await _firestore
            .collection("shop")
            .where("shop_id", isEqualTo: uid)
            .get();

        if (sellerQuery.docs.isNotEmpty) {
          final ShopModel shop = ShopModel.fromMap(
              sellerQuery.docs[0].data() as Map<String, dynamic>);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SellerHomeScreen(shop: shop)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SellerDetails()),
          );
        }
      }
    }
  }

  void logOut() {
    // Xử lý đăng xuất tại đây, ví dụ: xóa thông tin đăng nhập, xóa token, v.v.
    // Sau đó chuyển đến màn hình đăng nhập
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginScreen()), // Đảm bảo LoginIn được import
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF6),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 140, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Onboard!",
                style: AppTypography.textMd
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                "Select your user type.",
                textAlign: TextAlign.center,
                style: AppTypography.textSm.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 38),
              GestureDetector(
                onTap: () async {
                  await checkUserType("Buyer");
                },
                child: buildUserTypeContainer(
                  "Buyer",
                  "Join as a buyer, if you \nwant to purchase any \nitem or avail any \nservice",
                  "assets/images/buyer_type.png",
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  await checkUserType("Seller");
                },
                child: buildUserTypeContainer(
                  "Seller",
                  "Join as a seller, if you \nwant to sell any item \nor provide any \nservice.",
                  "assets/images/seller_type.png",
                ),
              ),
              const SizedBox(
                  height: 20), // Thay Spacer() bằng SizedBox để tránh overflow
              GestureDetector(
                onTap: () async {},
                child: buildContinueButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserTypeContainer(
      String title, String description, String imagePath) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 21, 10, 29),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFC8019)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style:
                    AppTypography.textMd.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.textSm.copyWith(fontSize: 14),
              )
            ],
          ),
          const Spacer(),
          Image.asset(imagePath, height: 130, width: 130),
        ],
      ),
    );
  }

  Widget buildContinueButton() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                logOut();
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red,
                ),
                child: Center(
                  child: Text("LOG OUT",
                      style: AppTypography.textMd.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
