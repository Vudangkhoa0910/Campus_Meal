import 'package:campus_catalogue/add_item.dart';
import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/order_model.dart';
import 'package:campus_catalogue/models/shopModel.dart';
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
    _widgetOptions = [
      homePage(),
      Text("History"),
      Text("Notifications"),
      Text("Profile")
    ];
  }

  @override
  Widget build(BuildContext context) {
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
          currentIndex: 0, // _selectedIndex should be managed if needed
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Text(
              "Explore IITG",
              style: AppTypography.textMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.backgroundOrange,
              ),
            ),
          ),
          const SizedBox(height: 20),
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
            style: AppTypography.textMd.copyWith(fontWeight: FontWeight.w700),
          ),
          FutureBuilder<List<dynamic>>(
            future: getOrders(),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
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
        ]),
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
