import 'package:campus_catalogue/constants/colors.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:campus_catalogue/screens/seller_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AddMenuItemPage extends StatefulWidget {
  final ShopModel shop;
  final List<dynamic> menu;

  const AddMenuItemPage({
    super.key,
    required this.shop,
    required this.menu,
  });

  @override
  State<AddMenuItemPage> createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Các trường nhập liệu
  String name = '';
  String description = '';
  num price = 0.0;
  bool vegetarian = false;
  String imgUrl = '';
  List<String> categories = [];

  XFile? sampleImage;
  bool isLoading = false;

  // Danh sách các categories có sẵn
  final List<String> allCategories = [
    'Italian',
    'Vegetarian',
    'Spicy',
    'Gluten-Free',
    // Thêm các categories khác ở đây
  ];

  // Hàm tải ảnh lên Firebase Storage và lấy URL
  Future<String> uploadImageToFirebase(File imageFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String fileName = 'shops/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = storage.ref().child(fileName);

    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Hàm chọn và tải ảnh
  Future<void> getImage() async {
    try {
      var image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          sampleImage = image;
          isLoading = true;
        });

        // Tải hình ảnh lên Firebase Storage
        String downloadUrl =
            await uploadImageToFirebase(File(sampleImage!.path));
        setState(() {
          imgUrl = downloadUrl;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Lỗi khi tải ảnh lên: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải ảnh lên: $e")),
      );
    }
  }

  // Hàm thêm menu vào Firestore
  Future<void> addMenu() async {
    // Kiểm tra các trường bắt buộc
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên menu")),
      );
      return;
    }

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập giá hợp lệ")),
      );
      return;
    }

    if (imgUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn và tải lên ảnh")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Tính toán key mới
      int newKey = 1;
      if (widget.menu.isNotEmpty) {
        List<int> keys =
            widget.menu.map((item) => item['key'] as int? ?? 0).toList();
        newKey =
            (keys.isNotEmpty ? keys.reduce((a, b) => a > b ? a : b) : 0) + 1;
      }

      // Tìm tài liệu shop theo shop_id
      QuerySnapshot querySnapshot = await _firestore
          .collection('shop')
          .where('shop_id', isEqualTo: widget.shop.shopID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Lấy docId của shop đầu tiên tìm được
        String docId = querySnapshot.docs.first.id;

        // Thêm menu mới vào Firestore
        await _firestore.collection('shop').doc(docId).update({
          'menu': FieldValue.arrayUnion([
            {
              'key': newKey,
              'name': name,
              'description': description,
              'price': price,
              'vegetarian': vegetarian,
              'img': imgUrl,
              'category': categories,
            }
          ]),
        });

        // Hiển thị thông báo thêm thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm menu thành công")),
        );

        // Tìm lại thông tin shop và điều hướng đến SellerHomeScreen
        QuerySnapshot shopSnapshot = await _firestore
            .collection('shop')
            .where('shop_id', isEqualTo: widget.shop.shopID)
            .get();

        if (shopSnapshot.docs.isNotEmpty) {
          // Điều hướng đến màn hình SellerHomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SellerHomeScreen(shop: widget.shop),
            ),
          );
        } else {
          // Nếu không tìm thấy shop
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Shop không tồn tại")),
          );
        }
      } else {
        // Không tìm thấy cửa hàng tương ứng
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy cửa hàng tương ứng")),
        );
      }
    } catch (e) {
      // Xử lý lỗi khi thêm menu
      print("Lỗi khi thêm menu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi thêm menu: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hàm thay đổi trạng thái chọn category
  void shiftCard(String category) {
    setState(() {
      if (categories.contains(category)) {
        categories.remove(category);
      } else {
        categories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            onPressed: () async {
              try {
                // Truy vấn Firestore dựa trên shop_id
                QuerySnapshot shopSnapshot = await FirebaseFirestore.instance
                    .collection('shop')
                    .where('shop_id', isEqualTo: widget.shop.shopID)
                    .get();

                if (shopSnapshot.docs.isNotEmpty) {
                  // Lấy document đầu tiên (giả sử mỗi shop_id là duy nhất)
                  DocumentSnapshot shopDoc = shopSnapshot.docs.first;
                  Map<String, dynamic> shopData =
                      shopDoc.data() as Map<String, dynamic>;

                  // Điều hướng đến màn hình SellerHomeScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerHomeScreen(shop: widget.shop),
                    ),
                  );
                } else {
                  // Nếu không tìm thấy shop
                  print("Shop không tồn tại");
                }
              } catch (e) {
                // Xử lý lỗi khi truy vấn Firestore
                print("Lỗi khi truy vấn Firestore: $e");
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xffF57C51),
            ),
          );
        }),
        title: const Text(
          "Add New Menu",
          style: TextStyle(color: AppColors.backgroundOrange),
        ),
        backgroundColor: Colors.amber[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chọn ảnh
            const Text(
              'Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : (imgUrl.isEmpty && sampleImage == null)
                    ? GestureDetector(
                        onTap: getImage,
                        child: Center(
                          child: Container(
                            height: 150,
                            width: 250,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.orange, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[200],
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.orange,
                              size: 50,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 150,
                            width: 250,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.orange, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: imgUrl != ''
                                  ? Image.network(
                                      imgUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(sampleImage!.path),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
            const SizedBox(height: 20),

            // Tên Menu
            const Text(
              'Item Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: AppColors.backgroundOrange, width: 1.5),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                onChanged: (val) {
                  setState(() {
                    name = val;
                  });
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter item name',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Giá
            const Text(
              'Price',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: AppColors.backgroundOrange, width: 1.5),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                onChanged: (val) {
                  setState(() {
                    price = double.tryParse(val) ?? 0.0;
                  });
                },
                initialValue: price == 0.0 ? '' : price.toString(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                ],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter price',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Checkbox Vegetarian
            Row(
              children: [
                Checkbox(
                  checkColor: AppColors.backgroundOrange,
                  activeColor: AppColors.backgroundYellow,
                  value: vegetarian,
                  onChanged: (bool? val) {
                    setState(() {
                      vegetarian = val ?? false;
                    });
                  },
                ),
                const Text(
                  'Vegetarian',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mô Tả
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: AppColors.backgroundOrange, width: 1.5),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                onChanged: (val) {
                  setState(() {
                    description = val;
                  });
                },
                initialValue: description,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter description',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            // const SizedBox(height: 20),

            // Chọn Categories
            // const Text(
            //   'Relevant Tags',
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // const SizedBox(height: 10),
            // Wrap(
            //   spacing: 8.0,
            //   runSpacing: 8.0,
            //   children: allCategories.map((category) {
            //     bool isSelected = categories.contains(category);
            //     return GestureDetector(
            //       onTap: () => shiftCard(category),
            //       child: Container(
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //         decoration: BoxDecoration(
            //           color: isSelected ? Colors.green : Colors.grey,
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //         child: Text(
            //           category,
            //           style: const TextStyle(color: Colors.white),
            //         ),
            //       ),
            //     );
            //   }).toList(),
            // ),
            const SizedBox(height: 30),

            // Nút Thêm Menu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : addMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundOrange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Done",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
