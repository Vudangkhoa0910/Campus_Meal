import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/screens/login.dart';
import 'package:campus_catalogue/screens/shop_chat.dart';
import 'package:campus_catalogue/screens/userType_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileUsePage extends StatefulWidget {
  Buyer buyer;
  ProfileUsePage({super.key, required this.buyer});

  @override
  State<ProfileUsePage> createState() => ProfileUsePageState();
}

class ProfileUsePageState extends State<ProfileUsePage> {
  bool _isEditable = false;
  bool _isUpdating = false;
  String _updateMessage = '';
  bool _showMessage = false;

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
    setState(() {
      _isUpdating = true;
      _updateMessage = '';
      _showMessage = false;
    });

    try {
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
        setState(() {
          _updateMessage = 'Buyer information updated successfully!';
          _isEditable = false;
          _showMessage = true;
        });
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            _showMessage = false; // Ẩn thông báo
          });
        });
      } else {
        setState(() {
          _updateMessage = "No buyer found with the specified Buyer ID.";
          _showMessage = true;
        });
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            _showMessage = false; // Ẩn thông báo
          });
        });
      }
    } catch (e) {
      setState(() {
        _updateMessage = 'Error updating shop: $e';
        _showMessage = true;
      });
      print('Error updating buyer: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void logOut() {
    // Xử lý đăng xuất tại đây, ví dụ: xóa thông tin đăng nhập, xóa token, v.v.
    // Sau đó chuyển đến màn hình đăng nhập
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const LoginScreen()), // Đảm bảo LoginIn được import
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
                  height: 500,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
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
                      color: const Color.fromRGBO(122, 103, 238, 1), width: 3),
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
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
                  height: 40,
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(238, 118, 0, 1),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: const Center(
                    child: Text(
                      "UPDATE",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 65,
              left: 80,
              child: GestureDetector(
                onTap: () {
                  logOut();
                },
                child: Container(
                  width: 200,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: const Center(
                    child: Text(
                      "LOG OUT",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              left: 80,
              child: GestureDetector(
                onTap: () {
                  // Pass the buyer object when navigating to ShopSelectionScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopSelectionScreen(
                          buyer: widget.buyer), // Truyền buyer vào đây
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Chat",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_showMessage && _updateMessage.isNotEmpty)
              Positioned(
                bottom: 120,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _updateMessage.contains('Error')
                        ? Colors.redAccent
                        : Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _updateMessage,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
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
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 2 / 3,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide:
                  BorderSide(width: 2, color: Color.fromRGBO(238, 118, 0, 1)),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            hintText: hintText,
            focusedBorder: const OutlineInputBorder(
              borderSide:
                  BorderSide(width: 2, color: Color.fromRGBO(238, 118, 0, 1)),
              borderRadius: BorderRadius.all(
                  Radius.circular(10)), // Không có viền khi có tiêu điểm
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.edit,
                color: _isEditable
                    ? Colors.grey[400]
                    : const Color.fromRGBO(238, 118, 0, 1),
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
