import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/screens/login.dart';
import 'package:campus_catalogue/screens/shop_chat.dart';
import 'package:campus_catalogue/screens/userType_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  Map<String, dynamic>? weatherData;

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
    fetchWeather();
  }

  @override
  void dispose() {
    userNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> fetchWeather() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=Hanoi&appid=e0ea7c2430957c0b90c7a6375a5f8cba&units=metric',
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
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
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Bo góc cho hộp thoại
        ),
        backgroundColor: AppColors.backgroundYellow,
        title: Row(
          children: [
            Icon(Icons.exit_to_app, color: Colors.orange, size: 30), // Biểu tượng
            const SizedBox(width: 10),
            const Text(
              "LogOut | ChangeRole ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "What do you want to do next ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly, 
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(); 
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserType()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.swap_horiz),
            label: const Text("ChangeRole"),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(); 
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.logout, color: Colors.orange),
            label: const Text(
              "LogOut",
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      );
    },
  );
}


  IconData _getWeatherIcon(String main) {
  switch (main.toLowerCase()) {
    case 'clear':
      return Icons.wb_sunny;
    case 'clouds':
      return Icons.cloud;
    case 'rain':
      return Icons.umbrella;
    case 'snow':
      return Icons.ac_unit;
    case 'thunderstorm':
      return Icons.flash_on;
    default:
      return Icons.wb_cloudy;
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.backgroundYellow,
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
                  color: const Color.fromRGBO(238, 118, 0, 1),
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
        Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              child: Column(
                children: [
                  Text(
                    "CAMPUS MEAL",
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (weatherData != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getWeatherIcon(weatherData!['weather'][0]['main']),
                          color: const Color.fromARGB(255, 58, 179, 234),
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Hà Nội: ${weatherData!['main']['temp']}°C, ',
                          style: const TextStyle(
                              fontSize: 16.5, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        Text(
                          weatherData!['weather'][0]['description'],
                          style: const TextStyle(fontSize: 16.5, color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ],
                    )
                  else
                    const CircularProgressIndicator(),
                ],
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
              padding: const EdgeInsets.only(top: 205),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  inputText(userNameController, "User Name"),
                  inputText(phoneNumberController, "Phone Number"),
                  inputText(emailController, "Email"),
                  inputText(addressController, "Address"),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: updateBuyer,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(238, 118, 0, 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.update,  // Icon cho Update
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8), // Khoảng cách giữa icon và text
                            Text(
                              "Update",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopSelectionScreen(buyer: widget.buyer),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat,  // Icon cho Chat
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8), // Khoảng cách giữa icon và text
                            Text(
                              "Chat",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: logOut,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.exit_to_app,  // Icon cho LogOut/ChangeRole
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8), // Khoảng cách giữa icon và text
                            Text(
                              "Log Out | Change Role",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_showMessage && _updateMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          ),
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
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 2, color: Color.fromRGBO(238, 118, 0, 1)),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
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
