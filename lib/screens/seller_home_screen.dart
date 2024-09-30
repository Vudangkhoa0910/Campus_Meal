import 'package:campus_catalogue/add_item.dart';
import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/order_model.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:campus_catalogue/screens/userType_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:flutter/material.dart';

class OrderWrapper extends StatelessWidget {
  final List<dynamic> orders;
  const OrderWrapper({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Column(
            children: [
              OrderTile(
                buyerName: order["buyer_name"],
                buyerPhone: order["buyer_phone"],
                status: order["status"],
                totalAmount: order["total_amount"],
                txnId: order["txnId"],
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}

class SellerHomeScreen extends StatefulWidget {
  final ShopModel shop;

  const SellerHomeScreen({Key? key, required this.shop}) : super(key: key);

  @override
  _SellerHomeScreenState createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  List<Map<String, dynamic>> menu = [];
  final DatabaseService service = DatabaseService();

  double? screenWidth;
  double? screenHeight;
  bool _isEditable = false;

  Future<List<dynamic>> getOrders() async {
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection("orders")
        .where("shop_id", isEqualTo: widget.shop.shopID)
        .limit(10)
        .get();

    return ordersSnapshot.docs.map((doc) => doc.data()).toList();
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    // _isEditable = false;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final mediaQuery = MediaQuery.of(context);
    //   setState(() {
    //     screenWidth = mediaQuery.size.width;
    //     screenHeight = mediaQuery.size.height;
    //     // Thực hiện bất kỳ khởi tạo bổ sung nào tại đây
    //   });
    // });
    _widgetOptions = [
      homePage(),
      // Text("History"),

      // Text("Profine")
      historyPage("np", "4", "HN", "NP", "123"),
      Text("Notifications"),
      infoPage()
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Truy cập MediaQuery trực tiếp trong build
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    menu = List<Map<String, dynamic>>.from(widget.shop.menu.map((item) => {
          "name": item["name"],
          "price": item["price"],
          "vegetarian": item["vegetarian"],
          "description": item["description"],
          "category": item["category"],
        }));

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, color: Colors.black),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history, color: Colors.black),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, color: Colors.black),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined, color: Colors.black),
              label: 'Profile',
            ),
          ],
          currentIndex:
              _selectedIndex, // _selectedIndex should be managed if needed
          selectedItemColor: Colors.black,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        body: _widgetOptions.elementAt(_selectedIndex));
  }

  Widget homePage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundYellow,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.backgroundOrange,
          ),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserType())),
        ),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Explore IITG",
          style: AppTypography.textMd.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.backgroundOrange,
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundYellow,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
          child: Column(
            // Thêm Column để chứa các widget
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIncomeCard(),
              const SizedBox(height: 12),
              Text(
                "Shop Management",
                style: AppTypography.textMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 32),
              _buildUpdateMenuButton(context),
              const SizedBox(height: 12),
              Text(
                "Current Orders",
                style: AppTypography.textMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              FutureBuilder<List<dynamic>>(
                future: getOrders(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final orders = snapshot.data!;
                    return OrderWrapper(orders: orders);
                  } else {
                    return Text(
                      "No orders",
                      style: AppTypography.textMd.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget historyPage(
      // final ShopModel? shop,
      final String name,
      final String rating,
      final String location,
      // final List menu,
      final String ownerName,
      final String upiID) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundYellow,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.backgroundOrange,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        centerTitle: true,
        title: Text("Order History",
            style: AppTypography.textMd.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.backgroundOrange)),
      ),
      backgroundColor: AppColors.backgroundYellow,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              height: 120,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pin_drop_rounded,
                            size: 15,
                          ),
                          Text(location,
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.timelapse_rounded, size: 15),
                          Text("9 AM TO 10 PM",
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.shopping_cart, size: 15),
                          Text("4 ITEMS IN STOCK",
                              style: AppTypography.textMd.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                          // Text("${menu.length} ITEMS IN STOCK",
                          //     style: AppTypography.textMd.copyWith(
                          //         fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Container(
                          width: 30,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.signIn),
                          child: Row(
                            children: [
                              Text(
                                "0",
                                style: AppTypography.textSm.copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const Icon(
                                Icons.star,
                                size: 15,
                              )
                            ],
                          ))
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "All Orders",
                style: AppTypography.textMd
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            // for (var item in menu)
            // ItemCard(
            //     name: item["name"],
            //     price: item["price"],
            //     description: item["description"],
            //     vegetarian: item["veg"],
            //     img: item["img"]),
          ],
        ),
      ),
    );
  }

  Widget infoPage() {
    late TextEditingController ownerNameController;
    late TextEditingController phoneNumberController;
    late TextEditingController shopNameController;
    late TextEditingController openingTimeController;
    late TextEditingController closingTimeController;
    late TextEditingController upiIdController;

    ownerNameController = TextEditingController(text: widget.shop.ownerName);
    phoneNumberController =
        TextEditingController(text: widget.shop.phoneNumber);
    shopNameController = TextEditingController(text: widget.shop.shopName);
    openingTimeController =
        TextEditingController(text: widget.shop.openingTime);
    closingTimeController =
        TextEditingController(text: widget.shop.closingTime);
    upiIdController = TextEditingController(text: widget.shop.upiId);

    Future<void> updateShop() async {
      // Tìm kiếm document dựa trên điều kiện
      final shopQuery = FirebaseFirestore.instance
          .collection('shop')
          .where('shop_id', isEqualTo: widget.shop.shopID);

      // Lấy snapshot của document
      final querySnapshot = await shopQuery.get();

      if (querySnapshot.docs.isNotEmpty) {
        // Giả sử bạn muốn cập nhật document đầu tiên tìm thấy
        final shopRef = querySnapshot.docs.first.reference;

        await shopRef.update({
          'owner_name': ownerNameController.text,
          'phone_number': phoneNumberController.text,
          'shop_name': shopNameController.text,
          'opening_time': openingTimeController.text,
          'closing_time': closingTimeController.text,
          'upi_id': upiIdController.text,
        });
      } else {
        print("No shop found with the specified UPI ID.");
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundYellow,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.backgroundOrange,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        centerTitle: true,
        title: Text("Profine",
            style: AppTypography.textMd.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.backgroundOrange)),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 150,
                  width: 500,
                  // height: screenHeight! * 1 / 5,
                  // width: screenWidth,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: Colors.amber[900]),
                ),
                Container(
                  // height: screenHeight! * 0.5,
                  // width: screenWidth,
                  height: 500,
                  width: 500,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                      color: Colors.white),
                ),
              ],
            ),
            Positioned(
                top: 80,
                left: 200,
                child: Container(
                  height: 130,
                  width: 130,
                  // height: screenHeight! * 0.2,
                  // width: screenHeight! * 0.2,
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
                )),
            Positioned(
                bottom: 80,
                left: 140,
                child: Column(
                  children: [
                    inputText(ownerNameController),
                    inputText(phoneNumberController),
                    inputText(shopNameController),
                    inputText(openingTimeController),
                    inputText(closingTimeController),
                    inputText(upiIdController),
                  ],
                )),
            Positioned(
                top: 60,
                left: 130,
                child: Container(
                  height: 120,
                  width: 120,
                  // height: screenHeight! * 0.2,
                  // width: screenHeight! * 0.2,
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
                )),
            Positioned(
                bottom: 45,
                left: 55,
                child: Column(
                  children: [
                    inputText(ownerNameController, "Owner Name"),
                    inputText(phoneNumberController, "Phone Number"),
                    inputText(shopNameController, "Shop Name"),
                    inputText(openingTimeController, "Opening Time"),
                    inputText(closingTimeController, "Closing Time"),
                    inputText(upiIdController, "Upi Id"),
                  ],
                )),
            Positioned(
              bottom: -5,
              left: 90,
              child: GestureDetector(
                onTap: () {
                  updateShop();
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

  Widget inputText(TextEditingController text, String hintText) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        width: 250,
        // width: screenWidth! * 2 / 3,
        child: TextFormField(
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
                  if (_isEditable) {
                    _isEditable = false;
                  } else {
                    _isEditable = true;
                  }
                });
              },
            ),
          ),
          // readOnly: _isEditable,
          controller: text,
        ),
      ),
    );
  }

  Widget _buildIncomeCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundYellow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: AppColors.backgroundOrange),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today’s income",
                style: AppTypography.textMd.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Rs. 0.00",
                style: AppTypography.textMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.backgroundOrange,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "UPI ID",
                style: AppTypography.textMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.shop.upiId,
                style: AppTypography.textMd.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateMenuButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditMenu(menu: menu)),
        ),
        child: Container(
          width: 340,
          padding: const EdgeInsets.symmetric(vertical: 35),
          decoration: BoxDecoration(
            color: AppColors.signIn,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "Update Menu",
              style: AppTypography.textMd.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  final String buyerPhone;
  final String buyerName;
  final String txnId;
  final String status;
  final int totalAmount;

  const OrderTile({
    Key? key,
    required this.buyerName,
    required this.buyerPhone,
    required this.status,
    required this.totalAmount,
    required this.txnId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.signIn,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                buyerPhone,
                style: AppTypography.textMd.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                buyerName,
                style: AppTypography.textMd.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildActionButton(
                      "CONFIRM", AppColors.backgroundOrange, Colors.white),
                  const SizedBox(width: 8),
                  _buildActionButton(
                      "REJECT", AppColors.backgroundYellow, Colors.black),
                  const SizedBox(width: 8),
                  _buildActionButton(
                      "VIEW", AppColors.backgroundYellow, Colors.black),
                ],
              ),
              Text(
                "Rs. $totalAmount",
                textAlign: TextAlign.end,
                style: AppTypography.textMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: AppTypography.textMd.copyWith(
          color: textColor,
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),
    );
  }
}
