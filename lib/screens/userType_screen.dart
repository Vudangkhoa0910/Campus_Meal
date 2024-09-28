import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:campus_catalogue/screens/home_screen.dart';
import 'package:campus_catalogue/screens/seller_home_screen.dart';
import 'package:campus_catalogue/screens/sign_in.dart';
import 'package:campus_catalogue/screens/userInformation/buyer_details.dart';
import 'package:campus_catalogue/screens/userInformation/seller_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserType extends StatefulWidget {
  const UserType({Key? key}) : super(key: key);

  @override
  _UserTypeState createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF6),
      body: SingleChildScrollView(
        child: Padding(
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
                  try {
                    QuerySnapshot buyerSnapshot = await FirebaseFirestore
                        .instance
                        .collection('Buyer')
                        .where('phone', isEqualTo: SignIn.phoneNumber)
                        .get();
                    print(buyerSnapshot.docs);

                    if (buyerSnapshot.docs.isNotEmpty) {
                      // Shop tồn tại, chuyển dữ liệu về ShopModel
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BuyerDetails()),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      print(e);
                    });
                  }
                },
                child: Container(
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
                            "Buyer",
                            style: AppTypography.textMd
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Join as a buyer, if you \nwant to purchase any \nitem or avail any \nservice",
                            style: AppTypography.textSm.copyWith(fontSize: 14),
                          )
                        ],
                      ),
                      const Spacer(),
                      Image.asset(
                        "assets/images/buyer_type.png",
                        height: 130,
                        width: 130,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  // Add your continue logic here, e.g., navigation or validation
                  try {
                    QuerySnapshot shopSnapshot = await FirebaseFirestore
                        .instance
                        .collection('shop')
                        .where('phone_number', isEqualTo: SignIn.phoneBasic)
                        .get();
                    print(shopSnapshot.docs);
                    for (var doc in shopSnapshot.docs) {
                      var shopData = doc.data() as Map<String, dynamic>;

                      print('Shop ID: ${shopData['shop_id']}');
                      print('Shop Name: ${shopData['shop_name']}');
                      print('Phone Number: ${shopData['phone_number']}');
                      print('Owner Name: ${shopData['owner_name']}');

                      // Nếu menu là một danh sách
                      List<dynamic> menuList = shopData['menu'] ?? [];
                      for (var menu in menuList) {
                        print('Menu Item: $menu');
                      }
                    }

                    if (shopSnapshot.docs.isNotEmpty) {
                      // Shop tồn tại, chuyển dữ liệu về ShopModel
                      Map<String, dynamic> shopData = shopSnapshot.docs.first
                          .data() as Map<String, dynamic>;
                      ShopModel shop = ShopModel.fromMap(shopData);

                      // Điều hướng sang SellerHomeScreen với dữ liệu shop
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellerHomeScreen(shop: shop),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SellerDetails()),
                      );
                    }
                  } catch (e) {
                    setState(() {
                      print(e);
                    });
                  }
                },
                child: Container(
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
                            "Seller",
                            style: AppTypography.textMd
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Join as a seller, if you \nwant to sell any item \nor provide any \nservice.",
                            style: AppTypography.textSm.copyWith(fontSize: 14),
                          )
                        ],
                      ),
                      const Spacer(),
                      Image.asset(
                        "assets/images/seller_type.png",
                        height: 130,
                        width: 130,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                child: Row(
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
                            child: Text(
                              "Continue",
                              style: AppTypography.textMd.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
