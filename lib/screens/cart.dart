import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/item_model.dart';
import 'package:campus_catalogue/screens/payment_info.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  Cart({Key? key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<ItemModel> items = []; // Danh sách sản phẩm
  List<int> quantities = []; // Danh sách số lượng cho từng sản phẩm
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _initRetrieval(); // Khởi tạo dữ liệu giỏ hàng
  }

  // Tạo ra 5 sản phẩm giả lập
  void _initRetrieval() {
    items = [
      ItemModel(
        name: "Salad",
        price: 5.0,
        category: "Vegetarian",
        vegetarian: true,
        description: "Fresh green salad.",
        imgUrl: "assets/images2/1727721224081.jpg",
      ),
      ItemModel(
        name: "Pasta",
        price: 7.5,
        category: "Non-Vegetarian",
        vegetarian: false,
        description: "Delicious pasta with tomato sauce.",
        imgUrl: "assets/images2/1727721280733.jpg",
      ),
      ItemModel(
        name: "Burger",
        price: 8.0,
        category: "Non-Vegetarian",
        vegetarian: false,
        description: "Juicy beef burger.",
        imgUrl: "assets/images2/1727753628084.jpg",
      ),
      ItemModel(
        name: "Fruit Bowl",
        price: 4.0,
        category: "Vegetarian",
        vegetarian: true,
        description: "Assorted fresh fruits.",
        imgUrl: "assets/images2/1727753556762.jpg",
      ),
      ItemModel(
        name: "Smoothie",
        price: 6.0,
        category: "Vegetarian",
        vegetarian: true,
        description: "Healthy fruit smoothie.",
        imgUrl: "assets/images2/1727721259019.jpg",
      ),
    ];
    
    // Khởi tạo danh sách số lượng cho từng sản phẩm
    quantities = List.filled(items.length, 1); // Mặc định là 1 cho mỗi sản phẩm

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Tính tổng giá tiền
    totalPrice = items.asMap().entries.fold(0, (total, entry) {
      int index = entry.key;
      ItemModel item = entry.value;
      return total + (item.price * quantities[index]);
    });

    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 36),
        child: Column(
          children: [
            SizedBox(
              height: 400,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return ItemCard(
                    item: items[index],
                    quantity: quantities[index], // Truyền số lượng cho ItemCard
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  height: 10,
                ),
                itemCount: items.length,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(width: 2, color: Colors.black),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Grand total"),
                      const Spacer(),
                      Text("\$${totalPrice.toStringAsFixed(2)}")
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentInfo()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: 60,
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

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final int quantity; // Thêm tham số quantity

  const ItemCard({
    Key? key,
    required this.item,
    required this.quantity, // Nhận tham số quantity
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 2), // Border màu cam
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2), // Thêm bóng
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // Đẩy bóng xuống dưới
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Image.asset(
            item.imgUrl,
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
                  item.name,
                  style: AppTypography.textSm.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Price: \$${item.price.toStringAsFixed(2)}",
                  style: AppTypography.textSm.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  "Quantity: $quantity", // Hiển thị số lượng
                  style: AppTypography.textSm.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
