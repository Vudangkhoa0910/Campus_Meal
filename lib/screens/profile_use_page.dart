import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Đảm bảo rằng bạn đã import trang đăng nhập

class ProfileUsePage extends StatefulWidget {
  final Buyer buyer; // Keep the buyer variable as final
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
    try {
      final buyerQuery = FirebaseFirestore.instance
          .collection('Buyer')
          .where('user_id', isEqualTo: widget.buyer.user_id);

      final querySnapshot = await buyerQuery.get();

      if (querySnapshot.docs.isNotEmpty) {
        final buyerRef = querySnapshot.docs.first.reference;

        await buyerRef.update({
          'user_name': userNameController.text,
          'phone': phoneNumberController.text,
          'email': emailController.text,
          'address': addressController.text
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Thông tin đã được lưu thành công!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditable = false; 
        });
      } else {
        print("No buyer found");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Không tìm thấy người mua"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi lưu thông tin: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void logOut() {
    // Xử lý đăng xuất tại đây, ví dụ: xóa thông tin đăng nhập, xóa token, v.v.
    // Sau đó chuyển đến màn hình đăng nhập
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Đảm bảo LoginIn được import
    );
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
                  height: MediaQuery.of(context).size.height - 120,
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
              top: 15,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Campus Meal",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Color.fromRGBO(122, 103, 238, 1), width: 3),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    "assets/Ảnh.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 220),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    inputText(userNameController, "User Name"),
                    inputText(phoneNumberController, "Phone Number"),
                    inputText(emailController, "Email"),
                    inputText(addressController, "Address"),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        updateBuyer();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 2 / 3,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(238, 118, 0, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: logOut, // Gọi phương thức logOut khi nút được nhấn
                      child: Container(
                        width: MediaQuery.of(context).size.width * 2 / 3,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.red, // Màu nền cho nút đăng xuất
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Log Out",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputText(TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: MediaQuery.of(context).size.width * 2 / 3,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 2, color: _isEditable 
                      ? Color.fromRGBO(238, 118, 0, 1)
                      : Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]), // Hint text color
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
