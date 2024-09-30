import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/screens/userType_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileUsePage extends StatefulWidget {
  Buyer buyer;
  ProfileUsePage({super.key, required this.buyer});

  @override
  State<ProfileUsePage> createState() => _ProfileUsePageState();
}

class _ProfileUsePageState extends State<ProfileUsePage> {
  bool _isEditable = false;

  late TextEditingController userNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();

    userNameController = TextEditingController(text: widget.buyer.userName);
    phoneNumberController = TextEditingController(text: widget.buyer.phone);
    emailController = TextEditingController(text: widget.buyer.email);
    addressController = TextEditingController(text: widget.buyer.address);
  }

  @override
  void dispose() {
    userNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> updateBuyer() async {
    // Tìm kiếm document dựa trên điều kiện
    final buyerQuery = FirebaseFirestore.instance
        .collection('Buyer')
        .where('user_id', isEqualTo: widget.buyer.user_id);

    // Lấy snapshot của document
    final querySnapshot = await buyerQuery.get();

    if (querySnapshot.docs.isNotEmpty) {
      // Giả sử bạn muốn cập nhật document đầu tiên tìm thấy
      final buyerRef = querySnapshot.docs.first.reference;

      await buyerRef.update({
        'user_name': userNameController.text,
        'phone': phoneNumberController.text,
        'email': emailController.text,
        'address': addressController.text
      });
    } else {
      print("No buyer found ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.amber[900],
                  ),
                ),
                Container(
                  height: 500,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 60,
              left: 120,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Color.fromRGBO(122, 103, 238, 1), width: 3),
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    "assets/iconprofile.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 170,
              left: 55,
              child: Column(
                children: [
                  inputText(userNameController, "User Name"),
                  inputText(phoneNumberController, "Phone Number"),
                  inputText(emailController, "Email"),
                  inputText(addressController, "Address")
                ],
              ),
            ),
            Positioned(
              bottom: 115,
              left: 80,
              child: GestureDetector(
                onTap: () {
                  updateBuyer();
                },
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(238, 118, 0, 1),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Center(
                    child: Text(
                      "Lưu",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget inputText(TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        width: MediaQuery.of(context).size.width * 2 / 3,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 2, color: Color.fromRGBO(238, 118, 0, 1)),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            hintText: hintText,
            suffixIcon: IconButton(
              icon: Icon(
                Icons.edit,
                color: _isEditable
                    ? Colors.grey[400]
                    : Color.fromRGBO(238, 118, 0, 1),
              ),
              onPressed: () {
                setState(() {
                  _isEditable = !_isEditable;
                });
              },
            ),
          ),
          readOnly: !_isEditable,
        ),
      ),
    );
  }
}
