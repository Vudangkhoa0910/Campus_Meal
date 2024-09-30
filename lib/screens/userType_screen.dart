import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/shopModel.dart';
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
    print("User UID: $uid");

    if (type == "Buyer") {
      QuerySnapshot buyerQuery = await _firestore
          .collection("Buyer")
          .where("user_id", isEqualTo: uid)
          .get();

      if (buyerQuery.docs.isNotEmpty) {
        // If Buyer exists, print the user_id from the document
        String buyerUserId = buyerQuery.docs[0]['user_id'];
        print("Buyer User ID (from Firestore): $buyerUserId");

        // Navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        print("No Buyer found with user_id: $uid");
        // Navigate to BuyerDetails
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BuyerDetails()),
        );
      }
    }

    if (type == "Seller") {
      QuerySnapshot sellerQuery = await _firestore
          .collection("shop")
          .where("shop_id", isEqualTo: uid)
          .get();

      if (sellerQuery.docs.isNotEmpty) {
        String shopId = sellerQuery.docs[0]['shop_id'];
        print("Shop ID (from Firestore): $shopId");

        ShopModel shop = ShopModel.fromMap(sellerQuery.docs[0].data() as Map<String, dynamic>);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SellerHomeScreen(shop: shop)),
        );
      } else {
        print("No Seller found with shop_id: $uid");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SellerDetails()),
        );
      }
    }
  } else {
    print("No user currently signed in.");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF6),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 140, 20, 36),
        child: Column(
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
              child: buildUserTypeContainer("Buyer",
                  "Join as a buyer, if you \nwant to purchase any \nitem or avail any \nservice", "assets/images/buyer_type.png"),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                await checkUserType("Seller");
              },
              child: buildUserTypeContainer("Seller",
                  "Join as a seller, if you \nwant to sell any item \nor provide any \nservice.", "assets/images/seller_type.png"),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {},
              child: buildContinueButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserTypeContainer(String title, String description, String imagePath) {
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
                style: AppTypography.textMd.copyWith(fontWeight: FontWeight.w500),
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
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xffF57C51),
              ),
              child: Center(
                child: Text("Continue",
                    style: AppTypography.textMd.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
