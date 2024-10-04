import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/models/item_model.dart';
import 'package:campus_catalogue/screens/payment_info.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  Buyer buyer;
  Cart({Key? key, required this.buyer}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<Map<String, dynamic>> items = []; // Danh sách sản phẩm từ Firebase
  List<int> quantities = []; // Danh sách số lượng cho từng sản phẩm
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _initRetrieval(); // Khởi tạo dữ liệu giỏ hàng
  }

  // Khởi tạo dữ liệu từ Firebase
  void _initRetrieval() async {
    final data = await DatabaseService()
        .getOrders(widget.buyer.userName); // Lấy dữ liệu từ Firebase

    if (data != null) {
      for (var order in data) {
        items.add({
          'name': order['name'],
          'price': order['price'],
          'imgUrl': order['imgUrl'], // Lấy hình ảnh từ Firebase
        });
        quantities.add(1); // Mặc định là 1 cho mỗi sản phẩm
      }

      if (mounted) {
        setState(() {}); // Cập nhật trạng thái
      }
    }
  }

  // Cập nhật số lượng từ các TextField
  void _updateQuantities() {
    for (var i = 0; i < items.length; i++) {
      final text = quantities[i].toString();
      quantities[i] =
          int.tryParse(text) ?? quantities[i]; // Cập nhật nếu có thay đổi
      print(quantities[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
        child: Column(
          children: [
            SizedBox(
              height: 400,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return ItemCard(
                    name: items[index]['name'], // Truyền tên sản phẩm
                    price: items[index]['price'], // Truyền giá sản phẩm
                    imgUrl: items[index]['imgUrl'], // Truyền hình ảnh sản phẩm
                    count: quantities[index], // Truyền số lượng cho ItemCard
                    onQuantityChanged: (newCount) {
                      quantities[index] =
                          newCount; // Cập nhật số lượng khi thay đổi
                    },
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  height: 10,
                ),
                itemCount: items.isNotEmpty
                    ? items.length
                    : 0, // Kiểm tra nếu danh sách không trống
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                _updateQuantities(); // Cập nhật số lượng từ các TextField
                await DatabaseService().updateOrdersQuantities(
                    items, quantities); // Cập nhật số lượng lên Firebase

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentInfo(
                            buyer: widget.buyer,
                          )),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xffF57C51),
                        ),
                        child: Center(
                          child: Text("Pay",
                              style: AppTypography.textMd.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
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
    );
  }
}

class ItemCard extends StatefulWidget {
  final String name; // Tên sản phẩm
  final double price; // Giá sản phẩm
  final String imgUrl; // Đường dẫn hình ảnh sản phẩm
  final num count; // Số lượng
  final Function(int) onQuantityChanged; // Callback để cập nhật số lượng

  ItemCard({
    Key? key,
    required this.name,
    required this.price,
    required this.imgUrl,
    required this.count, // Nhận tham số quantity
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final TextEditingController _controller = TextEditingController();
  int _count = 1;

  @override
  void initState() {
    super.initState();
    _count = widget.count.toInt(); // Khởi tạo số lượng từ widget
    _controller.text = _count.toString(); // Cập nhật controller với số lượng
  }

  void _increment() {
    setState(() {
      _count++;
      _controller.text = _count.toString();
      widget.onQuantityChanged(_count); // Gọi callback khi thay đổi số lượng
    });
  }

  void _decrement() {
    setState(() {
      if (_count > 1) {
        _count--;
        _controller.text = _count.toString();
        widget.onQuantityChanged(_count); // Gọi callback khi thay đổi số lượng
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Image.network(
            widget.imgUrl,
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: AppTypography.textSm.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Price: \$${widget.price.toStringAsFixed(2)}",
                  style: AppTypography.textSm.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _decrement,
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(width: 0.5, color: Colors.black),
                            color: Colors.amber[900]),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.remove,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      height: 25,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(width: 0.5, color: Colors.black),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 16),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: _increment,
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(width: 0.5, color: Colors.black),
                            color: Colors.amber[900]),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
