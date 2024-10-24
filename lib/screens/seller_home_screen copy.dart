// import 'package:campus_catalogue/add_item.dart';
// import 'package:campus_catalogue/constants/colors.dart';
// import 'package:campus_catalogue/constants/typography.dart';
// import 'package:campus_catalogue/models/order_model.dart';
// import 'package:campus_catalogue/models/shopModel.dart';
// import 'package:campus_catalogue/screens/login.dart';
// import 'package:campus_catalogue/screens/add_menu.dart';
// import 'package:campus_catalogue/screens/sele_buyer.dart';
// import 'package:campus_catalogue/screens/update_menu.dart';
// import 'package:campus_catalogue/screens/userType_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:campus_catalogue/services/database_service.dart';
// import 'package:flutter/material.dart';

// class OrderWrapper extends StatelessWidget {
//   final List<dynamic> orders;
//   const OrderWrapper({super.key, required this.orders});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: MediaQuery.of(context).size.height,
//       child: ListView.builder(
//         itemCount: orders.length,
//         itemBuilder: (context, index) {
//           final order = orders[index];
//           return Column(
//             children: [
//               OrderTile(
//                 buyerName: order["buyer_name"],
//                 buyerPhone: order["buyer_phone"],
//                 status: order["status"],
//                 totalAmount: order["total_amount"],
//                 txnId: order["txnId"],
//               ),
//               const SizedBox(height: 10),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   final ShopModel shop;
//   const HomePage({super.key, required this.shop});

//   @override
//   State<HomePage> createState() => HomePageState();
// }

// class HomePageState extends State<HomePage> {
//   List card = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   double totalIncome = 0.0;
//   List menu = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchOrders();
//     initializeMenu();
//   }

//   Future<void> fetchOrders() async {
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('orders')
//           .where('shop_name', isEqualTo: widget.shop.shopName)
//           .get();

//       setState(() {
//         card = snapshot.docs.map((doc) {
//           var data = doc.data() as Map<String, dynamic>;

//           totalIncome += (data['price'] ?? 0) as double;
//           return [
//             data['buyer_name'] ?? 'Unknown',
//             data['order_name'] ?? 'Unknown',
//             data['price']?.toString() ?? '0',
//             data['date'] ?? 'Unknown',
//             data['img'] ?? 'Unknown', // Đảm bảo 'img' tồn tại trong Firestore
//           ];
//         }).toList();
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error fetching orders: $e';
//         isLoading = false;
//       });
//       print('Error fetching orders: $e');
//     }
//   }

//   // List<Map<String, dynamic>> menu = [];
//   void initializeMenu() {
//     setState(() {
//       menu = List<Map<String, dynamic>>.from(widget.shop.menu.map((item) => {
//             "name": item["name"],
//             "price": item["price"],
//             "vegetarian": item["vegetarian"],
//             "description": item["description"],
//             "category": item["category"],
//             "img": item['img']
//           }));
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundYellow,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new_rounded,
//             color: AppColors.backgroundOrange,
//           ),
//           onPressed: () => Navigator.push(
//               context, MaterialPageRoute(builder: (context) => UserType())),
//         ),
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           "Explore IITG",
//           style: AppTypography.textMd.copyWith(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             color: AppColors.backgroundOrange,
//           ),
//         ),
//       ),
//       backgroundColor: AppColors.backgroundYellow,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
//           child: Column(
//             // Thêm Column để chứa các widget
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildIncomeCard(),
//               const SizedBox(height: 12),
//               Text(
//                 "Shop Management",
//                 style: AppTypography.textMd.copyWith(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 20,
//                 ),
//               ),
//               const SizedBox(height: 32),
//               _buildUpdateMenuButton(context),
//               const SizedBox(height: 12),
//               Text(
//                 "Menu",
//                 style: AppTypography.textMd.copyWith(
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               for (var item in menu)
//                 Container(
//                   padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
//                   child: Container(
//                       decoration: BoxDecoration(
//                           color: const Color(0xFFFFF2E0),
//                           borderRadius: BorderRadius.circular(10)),
//                       child: Container(
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.all(Radius.circular(20)),
//                             border: Border.all(
//                               width: 1.5,
//                               color: AppColors.backgroundOrange,
//                             )),
//                         padding: const EdgeInsets.all(10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Expanded(
//                               // Sửa để tránh lỗi overflow
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding:
//                                         const EdgeInsets.fromLTRB(0, 15, 0, 0),
//                                     child: Text(
//                                         // "User : ${item[0]}",
//                                         "Name : ${item['name']}",
//                                         style: AppTypography.textSm
//                                             .copyWith(fontSize: 14)),
//                                   ),
//                                   // Text(
//                                   //   "Order : ${item[1]}",
//                                   //   style: AppTypography.textSm.copyWith(
//                                   //       fontSize: 14,
//                                   //       fontWeight: FontWeight.w400),
//                                   // ),
//                                   Text(
//                                     // "Price : ${item[2]}",
//                                     "Price : ${item['price']}",
//                                     style: AppTypography.textSm.copyWith(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                   // Text(
//                                   //   "Count : ${item[3]}",
//                                   //   style: AppTypography.textSm.copyWith(
//                                   //       fontSize: 14,
//                                   //       fontWeight: FontWeight.w400),
//                                   // ),
//                                   Text(
//                                     "Description : ${item['description']}",
//                                     style: AppTypography.textSm.copyWith(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w400),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Spacer(),
//                             Container(
//                               height: 90,
//                               width: 90,
//                               decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: AppColors.backgroundOrange,
//                                       width: 1.5),
//                                   borderRadius: BorderRadius.circular(20)),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(20),
//                                 child: Image.network(
//                                   item['img'],
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Image.asset(
//                                       'assets/iconshop.jpg', // Đường dẫn đến hình ảnh thay thế
//                                       fit: BoxFit.cover,
//                                       width: double.infinity,
//                                       height: double.infinity,
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )),
//                 )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildIncomeCard() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundYellow,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(width: 2, color: AppColors.backgroundOrange),
//       ),
//       child: Row(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Today’s income",
//                 style: AppTypography.textMd.copyWith(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 "Rs. ${totalIncome.toStringAsFixed(2)}",
//                 style: AppTypography.textMd.copyWith(
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.backgroundOrange,
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 "UPI ID",
//                 style: AppTypography.textMd.copyWith(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 widget.shop.upiId,
//                 style: AppTypography.textMd.copyWith(fontSize: 12),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUpdateMenuButton(BuildContext context) {
//     final List<String> items = ["Update Menu", "Add Menu"];

//     return Center(
//       child: SizedBox(
//         height: 100, // Đảm bảo chiều cao cho ListView
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           itemCount: items.length,
//           itemBuilder: (BuildContext context, int index) {
//             return GestureDetector(
//               onTap: () {
//                 if (index == 0) {
//                   // Điều hướng đến trang chỉnh sửa menu
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) =>
//                             UpdateMenuItemPage(shop: widget.shop, menu: menu)),
//                   );
//                 } else if (index == 1) {
//                   // Điều hướng đến trang thêm menu
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) =>
//                             AddMenuItemPage(shop: widget.shop, menu: menu)),
//                   );
//                 }
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 5),
//                 child: Container(
//                   width: 160,
//                   padding: const EdgeInsets.symmetric(vertical: 35),
//                   decoration: BoxDecoration(
//                       color: AppColors.signIn,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         width: 1.5,
//                         color: AppColors.backgroundOrange,
//                       )),
//                   child: Center(
//                     child: Text(
//                       items[index],
//                       style: AppTypography.textMd.copyWith(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 20,
//                         color: AppColors.backgroundOrange,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class HistoryPage extends StatefulWidget {
//   final ShopModel shop;

//   const HistoryPage({Key? key, required this.shop}) : super(key: key);

//   @override
//   _HistoryPageState createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   List card = [];
//   bool isLoading = true;
//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchOrders();
//   }

//   Future<void> fetchOrders() async {
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('orders')
//           .where('shop_name', isEqualTo: widget.shop.shopName)
//           .get();

//       setState(() {
//         card = snapshot.docs.map((doc) {
//           var data = doc.data() as Map<String, dynamic>;
//           return [
//             data['buyer_name'] ?? 'Unknown',
//             data['order_name'] ?? 'Unknown',
//             data['price']?.toString() ?? '0',
//             data['date'] ?? 'Unknown',
//             data['img'] ?? 'Unknown', // Đảm bảo 'img' tồn tại trong Firestore
//           ];
//         }).toList();
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error fetching orders: $e';
//         isLoading = false;
//       });
//       print('Error fetching orders: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Order History",
//             style: AppTypography.textMd.copyWith(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: AppColors.backgroundOrange)),
//         backgroundColor: AppColors.backgroundYellow,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new_rounded,
//             color: AppColors.backgroundOrange,
//           ),
//           onPressed: () => Navigator.push(
//               context, MaterialPageRoute(builder: (context) => UserType())),
//         ),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       backgroundColor: AppColors.backgroundYellow,
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(child: Text(errorMessage))
//               : SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Thẻ thông tin cửa hàng hoặc bất kỳ widget nào bạn muốn hiển thị
//                       Container(
//                         margin: EdgeInsets.all(20),
//                         padding: EdgeInsets.all(20),
//                         height: 120,
//                         decoration: BoxDecoration(
//                             border: Border.all(color: Colors.black),
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(20))),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.pin_drop_rounded,
//                                       size: 15,
//                                     ),
//                                     Text(widget.shop.shopName,
//                                         style: AppTypography.textMd.copyWith(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w700)),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     Icon(Icons.timelapse_rounded, size: 15),
//                                     Text(
//                                         "${widget.shop.openingTime} AM TO ${widget.shop.closingTime} PM",
//                                         style: AppTypography.textMd.copyWith(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w700)),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     Icon(Icons.shopping_cart, size: 15),
//                                     Text("${card.length} ITEMS IN STOCK",
//                                         style: AppTypography.textMd.copyWith(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w700)),
//                                   ],
//                                 ),
//                                 Container(
//                                     width: 30,
//                                     padding: const EdgeInsets.all(2),
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(5),
//                                         color: AppColors.signIn),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           "0",
//                                           style: AppTypography.textSm.copyWith(
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.w700),
//                                         ),
//                                         const Icon(
//                                           Icons.star,
//                                           size: 15,
//                                         )
//                                       ],
//                                     ))
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Text(
//                           "All Orders",
//                           style: AppTypography.textMd.copyWith(
//                               fontSize: 20, fontWeight: FontWeight.w700),
//                         ),
//                       ),
//                       card.isEmpty
//                           ? Padding(
//                               padding: const EdgeInsets.all(20),
//                               child: Text(
//                                 "No orders found",
//                                 style: AppTypography.textMd.copyWith(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               shrinkWrap: true,
//                               physics: NeverScrollableScrollPhysics(),
//                               itemCount: card.length,
//                               itemBuilder: (context, index) {
//                                 final order = card[index];
//                                 return Padding(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(20, 0, 20, 5),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: const Color(0xFFFFF2E0),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(10),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.end,
//                                         children: [
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.fromLTRB(
//                                                           0, 15, 0, 0),
//                                                   child: Text(
//                                                       "User : ${order[0]}",
//                                                       style: AppTypography
//                                                           .textSm
//                                                           .copyWith(
//                                                               fontSize: 14)),
//                                                 ),
//                                                 Text(
//                                                   "Order : ${order[1]}",
//                                                   style: AppTypography.textSm
//                                                       .copyWith(
//                                                           fontSize: 14,
//                                                           fontWeight:
//                                                               FontWeight.w400),
//                                                 ),
//                                                 Text(
//                                                   "Price : ${order[2]}",
//                                                   style: AppTypography.textSm
//                                                       .copyWith(
//                                                           fontSize: 14,
//                                                           fontWeight:
//                                                               FontWeight.w400),
//                                                 ),
//                                                 Text(
//                                                   "Time : ${order[3]}",
//                                                   style: AppTypography.textSm
//                                                       .copyWith(
//                                                           fontSize: 14,
//                                                           fontWeight:
//                                                               FontWeight.w400),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           Spacer(),
//                                           Container(
//                                             height: 120,
//                                             width: 120,
//                                             decoration: BoxDecoration(
//                                                 border: Border.all(
//                                                     color: AppColors
//                                                         .backgroundOrange,
//                                                     width: 1.5),
//                                                 borderRadius:
//                                                     BorderRadius.circular(20)),
//                                             child: ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(20),
//                                               child: Image.network(
//                                                 order[4],
//                                                 fit: BoxFit.cover,
//                                                 errorBuilder: (context, error,
//                                                     stackTrace) {
//                                                   return Image.asset(
//                                                     'assets/iconshop.jpg',
//                                                     fit: BoxFit.cover,
//                                                     width: double.infinity,
//                                                     height: double.infinity,
//                                                   );
//                                                 },
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                     ],
//                   ),
//                 ),
//       // Nếu bạn muốn cuộn lên đầu khi có nhiều nội dung, hãy xem xét sử dụng ListView thay vì SingleChildScrollView với Column
//     );
//   }
// }

// class InfoPage extends StatefulWidget {
//   final ShopModel shop;

//   const InfoPage({Key? key, required this.shop}) : super(key: key);

//   @override
//   _InfoPageState createState() => _InfoPageState();
// }

// class _InfoPageState extends State<InfoPage> {
//   late TextEditingController ownerNameController;
//   late TextEditingController phoneNumberController;
//   late TextEditingController shopNameController;
//   late TextEditingController openingTimeController;
//   late TextEditingController closingTimeController;
//   late TextEditingController upiIdController;

//   bool _isEditable = false;
//   bool _isUpdating = false;
//   String _updateMessage = '';
//   bool _showMessage = false;

//   @override
//   void initState() {
//     super.initState();
//     ownerNameController = TextEditingController(text: widget.shop.ownerName);
//     phoneNumberController =
//         TextEditingController(text: widget.shop.phoneNumber);
//     shopNameController = TextEditingController(text: widget.shop.shopName);
//     openingTimeController =
//         TextEditingController(text: widget.shop.openingTime);
//     closingTimeController =
//         TextEditingController(text: widget.shop.closingTime);
//     upiIdController = TextEditingController(text: widget.shop.upiId);
//   }

//   @override
//   void dispose() {
//     ownerNameController.dispose();
//     phoneNumberController.dispose();
//     shopNameController.dispose();
//     openingTimeController.dispose();
//     closingTimeController.dispose();
//     upiIdController.dispose();
//     super.dispose();
//   }

//   Future<void> updateShop() async {
//     setState(() {
//       _isUpdating = true;
//       _updateMessage = '';
//       _showMessage = false;
//     });

//     try {
//       // Tìm kiếm document dựa trên điều kiện
//       final shopQuery = FirebaseFirestore.instance
//           .collection('shop')
//           .where('shop_id', isEqualTo: widget.shop.shopID);

//       // Lấy snapshot của document
//       final querySnapshot = await shopQuery.get();

//       if (querySnapshot.docs.isNotEmpty) {
//         // Giả sử bạn muốn cập nhật document đầu tiên tìm thấy
//         final shopRef = querySnapshot.docs.first.reference;

//         await shopRef.update({
//           'owner_name': ownerNameController.text,
//           'phone_number': phoneNumberController.text,
//           'shop_name': shopNameController.text,
//           'opening_time': openingTimeController.text,
//           'closing_time': closingTimeController.text,
//           'upi_id': upiIdController.text,
//         });

//         setState(() {
//           _updateMessage = 'Shop information updated successfully!';
//           _isEditable = false;
//           _showMessage = true;
//         });
//         Future.delayed(Duration(seconds: 5), () {
//           setState(() {
//             _showMessage = false; // Ẩn thông báo
//           });
//         });
//       } else {
//         setState(() {
//           _updateMessage = "No shop found with the specified Shop ID.";
//           _showMessage = true;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _updateMessage = 'Error updating shop: $e';
//         _showMessage = true;
//       });
//       print('Error updating shop: $e');
//     } finally {
//       setState(() {
//         _isUpdating = false;
//       });
//     }
//   }

//   void logOut() {
//     // Xử lý đăng xuất tại đây, ví dụ: xóa thông tin đăng nhập, xóa token, v.v.
//     // Sau đó chuyển đến màn hình đăng nhập
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//           builder: (context) => LoginScreen()), // Đảm bảo LoginIn được import
//     );
//   }

//   Widget inputText(TextEditingController controller, String hintText) {
//     return Padding(
//       padding: const EdgeInsets.all(5),
//       child: Container(
//         width: 250,
//         child: TextFormField(
//           decoration: InputDecoration(
//             enabledBorder: OutlineInputBorder(
//               borderSide:
//                   BorderSide(width: 2, color: Color.fromRGBO(238, 118, 0, 1)),
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               // Đổi thành OutlineInputBorder để giữ viền khi có focus
//               borderSide:
//                   BorderSide(width: 2, color: Color.fromRGBO(238, 118, 0, 1)),
//               borderRadius: BorderRadius.all(Radius.circular(10)),
//             ),
//             hintText: hintText,
//             suffixIcon: IconButton(
//               icon: Icon(
//                 Icons.edit,
//                 color: _isEditable
//                     ? Colors.grey[400]
//                     : Color.fromRGBO(238, 118, 0, 1),
//               ),
//               onPressed: () {
//                 setState(() {
//                   _isEditable = !_isEditable;
//                 });
//               },
//             ),
//           ),
//           readOnly: !_isEditable,
//           controller: controller,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Profile",
//             style: AppTypography.textMd.copyWith(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//                 color: AppColors.backgroundOrange)),
//         backgroundColor: AppColors.backgroundYellow,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new_rounded,
//             color: AppColors.backgroundOrange,
//           ),
//           onPressed: () => Navigator.push(
//               context, MaterialPageRoute(builder: (context) => UserType())),
//         ),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       backgroundColor: AppColors.backgroundYellow,
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 Container(
//                   height: 120,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20)),
//                       color: Colors.amber[900]),
//                 ),
//                 Container(
//                   height: 500,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(20),
//                           bottomRight: Radius.circular(20)),
//                       color: Colors.white),
//                 ),
//               ],
//             ),
//             Positioned(
//               top: 60,
//               left: MediaQuery.of(context).size.width / 2 -
//                   60, // Căn giữa hình ảnh
//               child: Container(
//                 height: 120,
//                 width: 120,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                       color: Color.fromRGBO(122, 103, 238, 1), width: 3),
//                   borderRadius: BorderRadius.all(Radius.circular(100)),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(100),
//                   child: Image.asset(
//                     "assets/iconprofile.png",
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 45,
//               left: (MediaQuery.of(context).size.width - 250) /
//                   2, // Căn giữa form
//               child: Column(
//                 children: [
//                   inputText(ownerNameController, "Owner Name"),
//                   inputText(phoneNumberController, "Phone Number"),
//                   inputText(shopNameController, "Shop Name"),
//                   inputText(openingTimeController, "Opening Time"),
//                   inputText(closingTimeController, "Closing Time"),
//                   inputText(upiIdController, "UPI ID"),
//                 ],
//               ),
//             ),
//             Positioned(
//               bottom: 0,
//               left:
//                   (MediaQuery.of(context).size.width - 300) / 2, // Căn giữa nút
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: _isUpdating
//                         ? null
//                         : () {
//                             if (_isEditable) {
//                               updateShop();
//                             }
//                           },
//                     child: Container(
//                       width: 100,
//                       height: 45,
//                       decoration: BoxDecoration(
//                           color: Color.fromRGBO(238, 118, 0, 1),
//                           borderRadius: BorderRadius.all(Radius.circular(10))),
//                       child: Center(
//                         child: _isUpdating
//                             ? CircularProgressIndicator(
//                                 valueColor:
//                                     AlwaysStoppedAnimation<Color>(Colors.white),
//                               )
//                             : Text(
//                                 "UPDATE",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       logOut();
//                     },
//                     child: Container(
//                       width: 100,
//                       height: 45,
//                       decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.all(Radius.circular(10))),
//                       child: Center(
//                         child: Text(
//                           "LOG OUT",
//                           style: TextStyle(
//                               color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   // Nút CHAT
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => BuyerSelectionScreen(
//                                 shop: widget
//                                     .shop)), // Điều hướng tới màn hình chat
//                       );
//                     },
//                     child: Container(
//                       width: 100,
//                       height: 45,
//                       decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: BorderRadius.all(Radius.circular(10))),
//                       child: Center(
//                         child: Text(
//                           "CHAT",
//                           style: TextStyle(
//                               color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (_showMessage && _updateMessage.isNotEmpty)
//               Positioned(
//                 bottom: 60,
//                 left: 20,
//                 right: 20,
//                 child: Container(
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: _updateMessage.contains('Error')
//                         ? Colors.redAccent
//                         : Colors.green,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     _updateMessage,
//                     style: TextStyle(color: Colors.white),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SellerHomeScreen extends StatefulWidget {
//   final ShopModel shop;

//   const SellerHomeScreen({Key? key, required this.shop}) : super(key: key);

//   @override
//   _SellerHomeScreenState createState() => _SellerHomeScreenState();
// }

// class _SellerHomeScreenState extends State<SellerHomeScreen> {
//   final DatabaseService service = DatabaseService();

//   double? screenWidth;
//   double? screenHeight;
//   bool _isEditable = false;

//   Future<List<dynamic>> getOrders() async {
//     final ordersSnapshot = await FirebaseFirestore.instance
//         .collection("orders")
//         .where("shop_id", isEqualTo: widget.shop.shopID)
//         .limit(10)
//         .get();

//     return ordersSnapshot.docs.map((doc) => doc.data()).toList();
//   }

//   int _selectedIndex = 0;
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   List<Widget> _widgetOptions = [];

//   @override
//   void initState() {
//     super.initState();

//     _widgetOptions = [
//       HomePage(shop: widget.shop),
//       HistoryPage(shop: widget.shop),
//       ntfPage(),
//       InfoPage(
//         shop: widget.shop,
//       ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Truy cập MediaQuery trực tiếp trong build
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//         bottomNavigationBar: BottomNavigationBar(
//           backgroundColor: Colors.white,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined, color: Colors.black),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.history, color: Colors.black),
//               label: 'History',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.notifications, color: Colors.black),
//               label: 'Notifications',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.account_circle_outlined, color: Colors.black),
//               label: 'Profile',
//             ),
//           ],
//           currentIndex:
//               _selectedIndex, // _selectedIndex should be managed if needed
//           selectedItemColor: Colors.black,
//           onTap: (index) {
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//         ),
//         body: _widgetOptions.elementAt(_selectedIndex));
//   }

//   Widget ntfPage() {
//     final List<Map<String, String>> notifications = [
//       {
//         "title": "Voucher giảm giá 20%",
//         "description": "Sử dụng mã: SAVE20 cho đơn hàng tiếp theo.",
//         "date": "01/10/2024",
//       },
//       {
//         "title": "Sự kiện ẩm thực",
//         "description": "Tham gia sự kiện ẩm thực vào thứ 7 này!",
//         "date": "02/10/2024",
//       },
//       {
//         "title": "Đơn hàng của bạn đã được xác nhận",
//         "description": "Đơn hàng #1234 sẽ được giao trong 30 phút.",
//         "date": "01/10/2024",
//       },
//       {
//         "title": "Thông tin mới về ứng dụng",
//         "description": "Cập nhật phiên bản mới với nhiều tính năng hấp dẫn.",
//         "date": "30/09/2024",
//       },
//       {
//         "title": "Khuyến mãi đặc biệt",
//         "description": "Giảm giá 15% cho đơn hàng từ 200.000đ.",
//         "date": "03/10/2024",
//       },
//       {
//         "title": "Hỗ trợ khách hàng",
//         "description": "Bạn có thể liên hệ với chúng tôi qua số hotline.",
//         "date": "29/09/2024",
//       },
//       {
//         "title": "Cập nhật món ăn mới",
//         "description": "Chúng tôi đã thêm món sushi mới vào menu.",
//         "date": "28/09/2024",
//       },
//     ];
//     return Scaffold(
//       body: ListView.builder(
//         itemCount: notifications.length,
//         itemBuilder: (context, index) {
//           return ntfcard(
//             notifications[index]["title"]!,
//             notifications[index]["description"]!,
//             notifications[index]["date"]!,
//           );
//         },
//       ),
//     );
//   }

//   Widget ntfcard(String title, String description, String date) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       color: Colors.amber[50],
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(
//               Icons.check_circle, // Biểu tượng tích xanh
//               color: Colors.green,
//               size: 24, // Kích thước biểu tượng
//             ),
//             const SizedBox(width: 10), // Khoảng cách giữa biểu tượng và tiêu đề
//             Expanded(
//               // Để tiêu đề và mô tả chiếm toàn bộ không gian còn lại
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color.fromARGB(255, 255, 145, 0),
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     description,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.black54,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Align(
//                     alignment: Alignment.bottomRight,
//                     child: Text(
//                       date,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class OrderTile extends StatelessWidget {
//   final String buyerPhone;
//   final String buyerName;
//   final String txnId;
//   final String status;
//   final int totalAmount;

//   const OrderTile({
//     Key? key,
//     required this.buyerName,
//     required this.buyerPhone,
//     required this.status,
//     required this.totalAmount,
//     required this.txnId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 80,
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: AppColors.signIn,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 buyerPhone,
//                 style: AppTypography.textMd.copyWith(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 buyerName,
//                 style: AppTypography.textMd.copyWith(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   _buildActionButton(
//                       "CONFIRM", AppColors.backgroundOrange, Colors.white),
//                   const SizedBox(width: 8),
//                   _buildActionButton(
//                       "REJECT", AppColors.backgroundYellow, Colors.black),
//                   const SizedBox(width: 8),
//                   _buildActionButton(
//                       "VIEW", AppColors.backgroundYellow, Colors.black),
//                 ],
//               ),
//               Text(
//                 "Rs. $totalAmount",
//                 textAlign: TextAlign.end,
//                 style: AppTypography.textMd.copyWith(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 10,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(
//       String label, Color backgroundColor, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(5),
//       ),
//       child: Text(
//         label,
//         style: AppTypography.textMd.copyWith(
//           color: textColor,
//           fontWeight: FontWeight.w400,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }
// }
