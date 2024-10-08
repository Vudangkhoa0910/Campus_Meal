import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateMenuItemPage extends StatefulWidget {
  final ShopModel shop;
  final List<dynamic> menu;

  const UpdateMenuItemPage({
    Key? key,
    required this.shop,
    required this.menu,
  }) : super(key: key);

  @override
  State<UpdateMenuItemPage> createState() => _UpdateMenuItemPageState();
}

class _UpdateMenuItemPageState extends State<UpdateMenuItemPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<Map<String, dynamic>> _menu;

  @override
  void initState() {
    super.initState();
    // Chuyển đổi List<dynamic> sang List<Map<String, dynamic>> để tăng độ an toàn kiểu dữ liệu
    _menu = widget.menu.map((item) {
      if (item is Map<String, dynamic>) {
        // Đảm bảo mỗi phần tử có 'key' hợp lệ

        return {
          'key': (item['key'] != null && item['key'] is num)
              ? item['key']
              : widget.menu.indexOf(item) + 1,
          'name': item['name'] ?? 'Unknown',
          'description': item['description'] ?? '',
          'price': item['price'] ?? 0,
          'vegetarian': item['vegetarian'] ?? false,
          'category': item['category'] ?? [],
          'img': item['img'] ?? '',
        };

        // return {
        //   'key': widget.menu.indexOf(item) + 1,
        //   'name': item['name'] ?? 'Unknown',
        //   'description': item['description'] ?? '',
        //   'price': item['price'] ?? 0,
        //   'vegetarian': item['vegetarian'] ?? false,
        //   'category': item['category'] ?? [],
        // };
      } else {
        // Nếu phần tử không phải là Map<String, dynamic>, gán giá trị mặc định
        return {
          'key': widget.menu.indexOf(item) + 1,
          'name': 'Unknown',
          'description': '',
          'price': 0,
          'vegetarian': false,
          'category': [],
        };
      }
    }).toList();
  }

  // Phương thức để làm mới danh sách menu từ Firestore
  Future<void> _refreshMenu() async {
    try {
      // Tìm tài liệu shop theo shop_id
      QuerySnapshot querySnapshot = await _firestore
          .collection('shop')
          .where('shop_id', isEqualTo: widget.shop.shopID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Lấy danh sách menu từ tài liệu shop
        List<dynamic> fetchedMenu = querySnapshot.docs.first['menu'];

        // Chuyển đổi và đảm bảo mỗi phần tử có 'key' hợp lệ
        List<Map<String, dynamic>> updatedMenu = fetchedMenu.map((item) {
          if (item is Map<String, dynamic>) {
            return {
              'key': (item['key'] != null && item['key'] is num)
                  ? item['key']
                  : fetchedMenu.indexOf(item) + 1,
              'name': item['name'] ?? 'Unknown',
              'description': item['description'] ?? '',
              'price': item['price'] ?? 0,
              'vegetarian': item['vegetarian'] ?? false,
            };
            // return {
            //   'key': item['key'].toString(),
            //   'name': item['name'] ?? 'Unknown',
            //   'description': item['description'] ?? '',
            //   'price': item['price'] ?? 0,
            //   'vegetarian': item['vegetarian'] ?? false,
            //   'category': [],
            // };
          } else {
            return {
              'key': fetchedMenu.indexOf(item) + 1,
              'name': 'Unknown',
              'description': '',
              'price': 0,
              'vegetarian': false,
            };
          }
        }).toList();

        setState(() {
          _menu = updatedMenu;
        });
      }
    } catch (e) {
      print("Lỗi khi lấy menu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lấy menu: $e")),
      );
    }
  }

  // Phương thức xoá món ăn
  Future<void> deleteMenuItem(num itemId) async {
    try {
      // Tìm tài liệu shop theo shop_id
      QuerySnapshot querySnapshot = await _firestore
          .collection('shop')
          .where('shop_id', isEqualTo: widget.shop.shopID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;

        // Xóa phần tử có key == itemId
        _menu.removeWhere((item) => item['key'] == itemId);

        // Không tái cấp 'key' để tránh gây lỗi
        // 'key' nên được duy trì là duy nhất và không thay đổi

        // Cập nhật danh sách menu mới lên Firestore
        await _firestore.collection('shop').doc(docId).update({
          'menu': _menu,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xoá món ăn thành công")),
        );

        // Làm mới danh sách menu trong UI
        await _refreshMenu();
      }
    } catch (e) {
      print("Lỗi khi xoá món ăn: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi xoá món ăn: $e")),
      );
    }
  }

  // Phương thức cập nhật món ăn
  Future<void> updateMenuItem(num itemId, String name, String description,
      num price, bool vegetarian) async {
    try {
      // Tìm tài liệu shop theo shop_id
      QuerySnapshot querySnapshot = await _firestore
          .collection('shop')
          .where('shop_id', isEqualTo: widget.shop.shopID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;

        // Tìm chỉ số của phần tử cần cập nhật trong danh sách _menu
        int index = _menu.indexWhere((item) => item['key'] == itemId);
        if (index == -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không tìm thấy món ăn để cập nhật")),
          );
          return;
        }

        // Cập nhật thông tin của phần tử đó
        _menu[index]['name'] = name;
        _menu[index]['description'] = description;
        _menu[index]['price'] = price;
        _menu[index]['vegetarian'] = vegetarian;
        _menu[index]['img'] = _menu[index]['img'];

        // Cập nhật danh sách menu mới lên Firestore
        await _firestore.collection('shop').doc(docId).update({
          'menu': _menu,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật món ăn thành công")),
        );

        // Làm mới danh sách menu trong UI
        await _refreshMenu();
      }
    } catch (e) {
      print("Lỗi khi cập nhật món ăn: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi cập nhật món ăn: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update Item",
          style: TextStyle(color: AppColors.backgroundOrange),
        ),
        backgroundColor: Colors.amber[100],
      ),
      body: ListView.builder(
        itemCount: _menu.length,
        itemBuilder: (context, index) {
          final item = _menu[index];
          final num itemId = item['key'] ?? 0;
          final String itemName = item['name'] ?? 'Unknown';
          final String itemDescription = item['description'] ?? '';
          final num itemPrice = item['price'] ?? 0;
          final bool itemVegetarian = item['vegetarian'] ?? false;

          // Kiểm tra item['key'] để đảm bảo không null hoặc rỗng
          // if (itemId == null || itemId.trim().isEmpty) {
          //   return Card(
          //     margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          //     child: ListTile(
          //       title: const Text("Invalid item"),
          //       subtitle: const Text("This item is missing a key."),
          //     ),
          //   );
          // }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: ListTile(
              title: Text(itemName),
              subtitle: Text('Price: ${itemPrice} - ${itemDescription}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Mở màn hình chỉnh sửa
                  showDialog(
                    context: context,
                    builder: (context) {
                      String newName = itemName;
                      String newDescription = itemDescription;
                      num newPrice = itemPrice;
                      bool newVegetarian = itemVegetarian;

                      TextEditingController nameController =
                          TextEditingController(text: newName);
                      TextEditingController descriptionController =
                          TextEditingController(text: newDescription);
                      TextEditingController priceController =
                          TextEditingController(text: newPrice.toString());

                      return StatefulBuilder(
                        builder: (context, setStateDialog) {
                          return AlertDialog(
                            title: const Text(
                              "Update Item",
                              style:
                                  TextStyle(color: AppColors.backgroundOrange),
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    decoration: const InputDecoration(
                                        labelText: 'Name'),
                                    onChanged: (value) {
                                      newName = value;
                                    },
                                    controller: nameController,
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                        labelText: 'Description'),
                                    onChanged: (value) {
                                      newDescription = value;
                                    },
                                    controller: descriptionController,
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                        labelText: 'Price'),
                                    onChanged: (value) {
                                      newPrice = double.tryParse(value) ?? 0.0;
                                    },
                                    controller: priceController,
                                    keyboardType: TextInputType.number,
                                  ),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: newVegetarian,
                                        onChanged: (value) {
                                          setStateDialog(() {
                                            newVegetarian = value ?? false;
                                          });
                                        },
                                      ),
                                      const Text("Vegetarian"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Kiểm tra dữ liệu hợp lệ trước khi cập nhật
                                  if (newName.trim().isEmpty ||
                                      newDescription.trim().isEmpty ||
                                      newPrice <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Vui lòng nhập đầy đủ thông tin")),
                                    );
                                    return;
                                  }

                                  // Kiểm tra itemId không null hoặc rỗng trước khi gọi phương thức
                                  if (itemId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Món ăn không hợp lệ")),
                                    );
                                    Navigator.of(context).pop();
                                    return;
                                  }

                                  updateMenuItem(itemId, newName,
                                      newDescription, newPrice, newVegetarian);
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "Update",
                                  style: TextStyle(
                                      color: AppColors.backgroundOrange),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Hiển thị hộp thoại xác nhận trước khi xóa
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Xác nhận xóa"),
                                        content: const Text(
                                            "Bạn có chắc chắn muốn xóa món ăn này không?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              // Kiểm tra itemId không null hoặc rỗng trước khi xóa
                                              if (itemId == null) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          "Món ăn không hợp lệ")),
                                                );
                                                Navigator.of(context)
                                                    .pop(); // Đóng hộp thoại xác nhận
                                                return;
                                              }

                                              deleteMenuItem(itemId);
                                              Navigator.of(context)
                                                  .pop(); // Đóng hộp thoại xác nhận
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: AppColors
                                                      .backgroundOrange),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Đóng hộp thoại xác nhận
                                            },
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: AppColors
                                                      .backgroundOrange),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                      color: AppColors.backgroundOrange),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: AppColors.backgroundOrange),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Thực hiện thêm món ăn mới
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
