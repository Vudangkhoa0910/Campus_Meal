import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/screens/payment_info.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  final Buyer buyer;
  Cart({Key? key, required this.buyer}) : super(key: key);

  @override
  CartState createState() => CartState();
}

class CartState extends State<Cart> with RouteAware {
  void reloadData() {
    _initRetrieval();
  }

  void removeItem(int index) async {
    final itemName = items[index]['name']; // Lấy tên item để xóa từ Firebase
    await DatabaseService()
        .deleteOrder(widget.buyer.userName, itemName); // Gọi phương thức xóa
    setState(() {
      items.removeAt(index);
      quantities.removeAt(index);
    });
  }

  List<Map<String, dynamic>> items = [];
  List<num> quantities = [];
  num totalPrice = 0;
  String selectedVoucher = '';
  TextEditingController voucherController =
      TextEditingController(); // Controller for voucher input

  // List of voucher options
  final List<Map<String, dynamic>> vouchers = [
    {
      'label': '10% OFF',
      'icon': Icons.percent,
      'description': 'Save 10% on your order'
    },
    {
      'label': '20% OFF',
      'icon': Icons.local_offer,
      'description': 'Get 20% discount on your total'
    },
    {
      'label': 'Free Shipping',
      'icon': Icons.local_shipping,
      'description': 'Enjoy free shipping on your order'
    },
    {
      'label': 'Buy 1 Get 1 Free',
      'icon': Icons.redeem,
      'description': 'Get another item for free!'
    },
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   _initRetrieval(); // Initialize and retrieve cart data
  // }

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

  // Update quantities of items based on user input
  void _updateQuantities() {
    for (var i = 0; i < items.length; i++) {
      final text = quantities[i].toString();
      quantities[i] = int.tryParse(text) ?? quantities[i]; // Update quantities
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
              height: 200,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return ItemCard(
                    name: items[index]['name'],
                    price: items[index]['price'],
                    imgUrl: items[index]['imgUrl'],
                    count: quantities[index],
                    onQuantityChanged: (newCount) {
                      quantities[index] = newCount;
                    },
                    onRemove: () => removeItem(index),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  height: 10,
                ),
                itemCount: items.isNotEmpty ? items.length : 0,
              ),
            ),
            const Spacer(),
            // Voucher section starts here
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voucher Discount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: voucherController,
                          decoration: InputDecoration(
                            hintText: 'Enter voucher code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2),
                          borderRadius:
                              BorderRadius.circular(8), // Bo viền góc tròn
                        ),
                        child: DropdownButton<String>(
                          value:
                              selectedVoucher.isEmpty ? null : selectedVoucher,
                          hint: const Text('Select voucher'),
                          items: vouchers.map((voucher) {
                            return DropdownMenuItem<String>(
                              value: voucher['label'],
                              child: Row(
                                children: [
                                  Icon(voucher['icon'], color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(voucher['label']),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedVoucher = value ?? '';
                              voucherController
                                  .clear(); // Clear manual entry if dropdown is selected
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
                height: 10), // Add space between voucher and pay button
            GestureDetector(
              onTap: () async {
                _updateQuantities(); // Update quantities from user input
                await DatabaseService().updateOrdersQuantities(
                    items, quantities, widget.buyer.userName);

                // Navigate to PaymentInfo screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentInfo(
                      buyer: widget.buyer,
                    ),
                  ),
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
                          child: Text(
                            "Pay",
                            style: AppTypography.textMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

// ItemCard widget to display each cart item
class ItemCard extends StatefulWidget {
  final String name;
  final num price;
  final String imgUrl;
  final num count;
  final Function(int) onQuantityChanged;
  final Function() onRemove; // Thêm hàm xóa

  ItemCard({
    Key? key,
    required this.name,
    required this.price,
    required this.imgUrl,
    required this.count,
    required this.onQuantityChanged,
    required this.onRemove, // Thêm hàm xóa
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
    _count = widget.count.toInt();
    _controller.text = _count.toString();
  }

  // Increment the quantity
  void _increment() {
    setState(() {
      _count++;
      _controller.text = _count.toString();
      widget.onQuantityChanged(_count);
    });
  }

  // Decrement the quantity
  void _decrement() {
    setState(() {
      if (_count > 1) {
        _count--;
        _controller.text = _count.toString();
        widget.onQuantityChanged(_count);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(255, 255, 146, 3), width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.imgUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Display product details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${widget.price}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          // Quantity controls
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _decrement,
          ),
          SizedBox(
            width: 15,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (value) {
                setState(() {
                  _count = int.tryParse(value) ?? 1;
                });
                widget.onQuantityChanged(_count);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _increment,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              widget.onRemove(); // Gọi hàm xóa khi nhấn nút
            },
          ),
        ],
      ),
    );
  }
}
