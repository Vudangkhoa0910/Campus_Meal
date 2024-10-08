import 'dart:io';

import 'package:campus_catalogue/add_item.dart';
import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:campus_catalogue/screens/seller_home_screen.dart';
import 'package:campus_catalogue/screens/userInformation/buyer_details.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
      backgroundColor: Color(0xFFFFFEF6), // Ensure you have a background color
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust to minimum required space
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.keyboard_arrow_left,
                      size: 32,
                      color: Color(0xFFFC8019),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "1/2",
                    style: AppTypography.textMd
                        .copyWith(color: const Color(0xFFFC8019)),
                  ),
                ],
              ),

              const SizedBox(height: 84),

              // Title
              Text(
                "Create New Seller Account",
                style: AppTypography.textMd
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 4),

              // Subtitle
              Text(
                "Please fill up all inputs to create a new seller account.",
                textAlign: TextAlign.center,
                style: AppTypography.textSm.copyWith(fontSize: 14),
              ),

              const SizedBox(height: 40),

              // Form Container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 0, color: const Color(0xFFFEC490)),
                  color: AppColors.signIn,
                ),
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop Name Field
                      FieldsFormat(
                        text: _shopNameController,
                        title: "Shop Name",
                        maxlines: 1,
                      ),

                      const SizedBox(height: 20),

                      // Shop Type Dropdown
                      Text(
                        "Shop Type",
                        style: AppTypography.textSm.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField2(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(width: 0),
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
                      ),

                      const SizedBox(height: 20),

                      // Location Dropdown
                      Text(
                        "Location",
                        style: AppTypography.textSm.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField2<String>(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundYellow,
                        ),
                        isExpanded: true,
                        hint: const Text(
                          'Select an option',
                          style: TextStyle(fontSize: 14),
                        ),
                        items: locationItems
                            .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ))
                            .toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select Location.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value.toString();
                          });
                        },
                        onSaved: (value) {
                          selectedLocation = value.toString();
                        },
                      ),

                      const SizedBox(height: 20),

                      // Opening and Closing Time
                      Row(
                        children: [
                          // Opening Time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Opening Time",
                                  style: AppTypography.textSm
                                      .copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 40,
                                  child: TextFormField(
                                    controller: _openingTimeController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter time';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.start,
                                    decoration: InputDecoration(
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          "AM",
                                          style: AppTypography.textSm
                                              .copyWith(fontSize: 14),
                                        ),
                                      ),
                                      suffixIconConstraints:
                                          const BoxConstraints(
                                              minHeight: 0, minWidth: 0),
                                      fillColor: AppColors.backgroundYellow,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          width: 0,
                                          color: AppColors.backgroundYellow,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          width: 0,
                                          color: AppColors.backgroundYellow,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Closing Time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Closing Time",
                                  style: AppTypography.textSm
                                      .copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 40,
                                  child: TextFormField(
                                    controller: _closingTimeController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter time';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.start,
                                    decoration: InputDecoration(
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          "PM",
                                          style: AppTypography.textSm
                                              .copyWith(fontSize: 14),
                                        ),
                                      ),
                                      suffixIconConstraints:
                                          const BoxConstraints(
                                              minHeight: 0, minWidth: 0),
                                      fillColor: AppColors.backgroundYellow,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          width: 0,
                                          color: AppColors.backgroundYellow,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          width: 0,
                                          color: AppColors.backgroundYellow,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Proceed Button
              GestureDetector(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerAdditional(
                          shopName: _shopNameController.text,
                          closingTime: _closingTimeController.text,
                          location: selectedLocation!,
                          openingTime: _openingTimeController.text,
                          shopType: selectedShopType!,
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xffF57C51),
                        ),
                        child: Center(
                          child: Text(
                            "Proceed",
                            style: AppTypography.textMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // Additional spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SellerAdditional extends StatefulWidget {
  final String shopName;
  final String shopType;
  String location;
  String openingTime;
  String closingTime;
  SellerAdditional(
      {Key? key,
      required this.shopName,
      required this.closingTime,
      required this.location,
      required this.openingTime,
      required this.shopType})
      : super(key: key);

  @override
  _SellerAdditionalState createState() => _SellerAdditionalState();
}

class _SellerAdditionalState extends State<SellerAdditional> {
  XFile? sampleImage;
  String imgUrl = "";
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    // Hủy bỏ bất kỳ công việc nào nếu cần thiết
    super.dispose();
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    try {
      // Tạo một reference trong Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName =
          'imageshop/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = storage.ref().child(fileName);

      // Tải lên file
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Lấy URL sau khi tải lên thành công
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }

  Future<void> getImage() async {
    try {
      print('Starting image picker...');
      var image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('Image picked: ${image.path}');

        // Kiểm tra xem widget còn mounted trước khi gọi setState
        if (!mounted) return;

        setState(() {
          sampleImage = image;
        });

        print('Uploading image to Firebase...');
        // Tải hình ảnh lên Firebase Storage
        String downloadUrl =
            await uploadImageToFirebase(File(sampleImage!.path));

        print('Image uploaded. URL: $downloadUrl');

        // Kiểm tra lại mounted sau khi tải ảnh
        if (!mounted) return;

        setState(() {
          imgUrl = downloadUrl;
        });

        // Bạn có thể lưu URL vào Firestore hoặc hiển thị trong giao diện
        print("Image uploaded! URL: $downloadUrl");
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print("Error picking/uploading image: $e");

      // Kiểm tra mounted trước khi gọi ScaffoldMessenger
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  List<dynamic> menu = [];
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alternatePhoneController =
      TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow the scaffold to resize when the keyboard appears
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFFEF6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 36),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Adjust to minimum required space
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.keyboard_arrow_left,
                        size: 32,
                        color: Color(0xFFFC8019),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "2/2",
                      style: AppTypography.textMd
                          .copyWith(color: const Color(0xFFFC8019)),
                    ),
                  ],
                ),

                const SizedBox(height: 84),

                // Form Container
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(width: 0, color: const Color(0xFFFEC490)),
                    color: AppColors.signIn,
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Owner Name Field
                        FieldsFormat(
                          text: _ownerNameController,
                          title: "Owner Name",
                          maxlines: 1,
                        ),

                        const SizedBox(height: 16),

                        // Phone Number Field
                        FieldsFormat(
                          text: _phoneController,
                          title: "Phone Number",
                          maxlines: 1,
                        ),

                        const SizedBox(height: 16),

                        // Alternate Phone Number Field
                        FieldsFormat(
                          text: _alternatePhoneController,
                          title: "Alternate Phone Number",
                          maxlines: 1,
                        ),

                        const SizedBox(height: 16),

                        // UPI ID Field
                        FieldsFormat(
                          text: _upiIdController,
                          title: "UPI ID",
                          maxlines: 1,
                        ),
                        const SizedBox(height: 16),
                        // add img
                        const Align(
                          child: Text('Image'),
                          alignment: Alignment.topLeft,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        sampleImage == null
                            ? GestureDetector(
                                onTap: () {
                                  getImage();
                                },
                                child: Center(
                                  child: Container(
                                    height: 150,
                                    width: 250,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.backgroundOrange,
                                            width: 1.5),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.backgroundOrange,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Material(
                                  elevation: 4.0,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                      height: 100,
                                      width: 150,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.backgroundOrange,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.file(
                                          File(sampleImage!.path),
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Add Food Items Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMenu(
                          menu: menu,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(width: 2, color: const Color(0xFFFC8019)),
                    ),
                    child: Text(
                      "Add Food Items",
                      style: AppTypography.textMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFC8019),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Proceed Button
                GestureDetector(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      DatabaseService service = DatabaseService();
                      final FirebaseAuth _auth = FirebaseAuth.instance;
                      final User? user = _auth.currentUser;

                      if (user == null) {
                        // Handle user not logged in
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('User not authenticated.')),
                        );
                        return;
                      }

                      ShopModel shop = ShopModel(
                        shopID: user.uid,
                        alternatePhoneNumber: _alternatePhoneController.text,
                        closingTime: widget.closingTime,
                        location: widget.location,
                        openingTime: widget.openingTime,
                        ownerName: _ownerNameController.text,
                        phoneNumber: _phoneController.text,
                        shopName: widget.shopName,
                        shopType: widget.shopType,
                        upiId: _upiIdController.text,
                        menu: menu,
                        status: true,
                        rating: {"rating": 0, "num_ratings": 2},
                        img: imgUrl,
                      );

                      await service.addShop(shop);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellerHomeScreen(
                            shop: shop,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xffF57C51),
                    ),
                    child: const Center(
                      child: Text(
                        "Proceed",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16, // Adjust font size as needed
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Additional spacing at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
