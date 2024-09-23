import 'package:campus_catalogue/add_item.dart';
import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:campus_catalogue/screens/seller_home_screen.dart';
import 'package:campus_catalogue/screens/userInformation/buyer_details.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellerDetails extends StatefulWidget {
  SellerDetails({Key? key}) : super(key: key);

  @override
  _SellerDetailsState createState() => _SellerDetailsState();
}

class _SellerDetailsState extends State<SellerDetails> {
  final List<String> shopTypeitems = [
    'Food and Beverages',
    'Restaurant',
    'Stationary',
  ];
  final List<String> locationItems = [
    'Hostel Canteen',
    'Hostel Juice Centre',
    'Market Complex',
    'Khokha Stalls',
    'Food Court',
    'Swimming Pool Area',
  ];

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _openingTimeController = TextEditingController();
  final TextEditingController _closingTimeController = TextEditingController();
  String selectedShopType = "";
  String selectedLocation = "";
  final _formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFFFFEF6),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 36),
        child: Column(children: [
          Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.keyboard_arrow_left,
                      size: 32,
                      color: Color(0xFFFC8019),
                    )),
              ),
              Spacer(),
              Text(
                "1/2",
                style: AppTypography.textMd.copyWith(color: Color(0xFFFC8019)),
              )
            ],
          ),
          const SizedBox(
            height: 84,
          ),
          Text(
            "Create New Seller Account",
            style: AppTypography.textMd
                .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            "Please fill up all inputs to create a new seller account.",
            textAlign: TextAlign.center,
            style: AppTypography.textSm.copyWith(fontSize: 14),
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 0, color: Color(0xFFFEC490)),
                  color: AppColors.signIn),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldsFormat(
                      text: _shopNameController,
                      title: "Shop Name",
                      maxlines: 1,
                    ),
                    Text(
                      "Shop Type",
                      style: AppTypography.textSm.copyWith(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    SizedBox(
                        height: 40,
                        child: DropdownButtonFormField2(
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(width: 0),
                            ),
                            filled: true,
                            fillColor: AppColors.backgroundYellow,
                          ),
                          isExpanded: true,
                          hint: const Text(
                            'Select an option',
                            style: TextStyle(fontSize: 14),
                          ),
                          items: shopTypeitems
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select an option.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedShopType = value.toString();
                            });
                          },
                          onSaved: (value) {
                            selectedShopType = value.toString();
                          },
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Location",
                      style: AppTypography.textSm.copyWith(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SellerAdditional(
                        shopName: _shopNameController.text,
                        closingTime: _closingTimeController.text,
                        location: selectedLocation,
                        openingTime: _openingTimeController.text,
                        shopType: selectedShopType)),
              );
            },
          )
        ]),
      ),
    );
  }
}
