import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/constants/typography.dart';
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/screens/payment_info.dart';
import 'package:campus_catalogue/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  final Buyer buyer;

  const Cart({super.key, required this.buyer});

  @override
  CartState createState() => CartState();
}

class CartState extends State<Cart> with RouteAware {
  List<Map<String, dynamic>> items = [];
  List<int> quantities = [];
  Set<String> selectedItems = {}; // Set to track selected items
  num totalPrice = 0;
  String selectedVoucher = '';
  int discount = 0;
  TextEditingController voucherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initRetrieval();
  }

  void _initRetrieval() {
    DatabaseService().getOrders(widget.buyer.userName).listen((data) {
      setState(() {
        items = data
            .map((order) => {
                  'name': order['name'],
                  'price': order['price'],
                  'imgUrl': order['imgUrl'],
                  'shop_name': order['shop_name'],
                })
            .toList();
        items.sort((a, b) => a['shop_name'].compareTo(b['shop_name'])); // Sort items by shop name
        quantities = List<int>.filled(items.length, 1);
      });
    });
  }

  void removeItem(String itemName) async {
    await DatabaseService().deleteOrder(widget.buyer.userName, itemName);
  }

  void addDiscount(int discount) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await _firestore
        .collection('buy')
        .where('buyer_name', isEqualTo: widget.buyer.userName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await _firestore.collection('buy').doc(doc.id).update({
          'discount': discount,
        }).catchError((e) {
          print("Error updating discount: $e");
        });
      }
    }
  }

  void _updateQuantities() {
    for (var i = 0; i < items.length; i++) {
      final text = quantities[i].toString();
      quantities[i] = int.tryParse(text) ?? quantities[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
        child: Column(
          children: [
            SizedBox(
              height: 500,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: DatabaseService().getOrders(widget.buyer.userName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Có lỗi xảy ra: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 90),
                          Text(
                            'CAMPUS MEAL',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No items in the cart. Please add in the shop',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data!;

                  items = List.from(data);
                  items.sort((a, b) => a['shop_name'].compareTo(b['shop_name']));
                  if (quantities.length != data.length) {
                    quantities = List<int>.filled(data.length, 1);
                  }

                  Map<String, List<Map<String, dynamic>>> groupedItems = {};
                  for (var item in items) {
                    groupedItems.putIfAbsent(item['shop_name'], () => []);
                    groupedItems[item['shop_name']]!.add(item);
                  }

                  return ListView.builder(
                    itemCount: groupedItems.length,
                    itemBuilder: (context, index) {
                      String shopName = groupedItems.keys.elementAt(index);
                      List<Map<String, dynamic>> shopItems =
                          groupedItems[shopName]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shopName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...shopItems.map((order) {
                            final imgUrl = order['imgUrl'] ?? '';
                            final index = items.indexOf(order);

                            return ItemCard(
                              name: order['name'],
                              price: order['price'],
                              shopName: shopName,
                              imgUrl: imgUrl.isNotEmpty
                                  ? imgUrl
                                  : 'default_image_url',
                              count: quantities[index],
                              isSelected: selectedItems.contains(order['name']),
                              onSelected: (isSelected) {
                                setState(() {
                                  if (isSelected) {
                                    selectedItems.add(order['name']);
                                  } else {
                                    selectedItems.remove(order['name']);
                                  }
                                });
                              },
                              onQuantityChanged: (newCount) {
                                setState(() {
                                  quantities[index] = newCount;
                                });
                              },
                              onRemove: () {
                                removeItem(order['name']);
                              },
                            );
                          }).toList(),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                final selectedOrders = items
                    .where((item) => selectedItems.contains(item['name']))
                    .toList();

                if (selectedOrders.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No items selected for payment.')),
                  );
                  return;
                }

                // Kiểm tra nếu tất cả mặt hàng đều từ một shop
                final shopNames = selectedOrders.map((item) => item['shop_name']).toSet();
                if (shopNames.length > 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You can only pay for items from one shop at a time.')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentInfo(
                      buyer: widget.buyer,
                      selectedOrders: selectedOrders, // Truyền danh sách sản phẩm được chọn
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
                        child: const Center(
                          child: Text(
                            "Pay",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final String name;
  final num price;
  final String shopName;
  final String imgUrl;
  final num count;
  final bool isSelected;
  final Function(bool) onSelected;
  final Function(int) onQuantityChanged;
  final Function() onRemove;

  const ItemCard({
    Key? key,
    required this.name,
    required this.price,
    required this.shopName,
    required this.imgUrl,
    required this.count,
    required this.isSelected,
    required this.onSelected,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    color: const Color.fromARGB(255, 255, 252, 225), 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), 
      side: BorderSide(
        color: Colors.orange, 
        width: 2, 
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              if (value != null) {
                onSelected(value);
              }
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12), 
            child: Image.network(
              imgUrl,
              width: 80,  
              height: 80, 
              fit: BoxFit.cover, 
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,  
                  height: 80, 
                  color: Colors.grey.shade300, 
                  child: const Icon(Icons.image, color: Colors.grey), 
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Price: \$${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (count > 1) {
                              onQuantityChanged((count - 1).toInt());
                            }
                          },
                        ),
                        Text('$count',
                            style: const TextStyle(
                              fontSize: 16,
                            )),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            onQuantityChanged((count + 1).toInt());
                          },
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onRemove,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

