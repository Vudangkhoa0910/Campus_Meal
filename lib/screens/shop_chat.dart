import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart'; // Đảm bảo import đúng file ChatScreen
import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/models/shopModel.dart';

class ShopSelectionScreen extends StatelessWidget {
  final Buyer buyer; // Thay đổi kiểu dữ liệu để nhận đối tượng Buyer

  const ShopSelectionScreen({Key? key, required this.buyer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Shop'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('shop').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final shops = snapshot.data!.docs;
          return ListView.builder(
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shopData = shops[index].data() as Map<String, dynamic>;

              // Tạo đối tượng ShopModel từ dữ liệu shop
              final shopModel = ShopModel.fromMap(shopData);

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: Colors.orangeAccent,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(15),
                  leading: shopModel.img.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            shopModel.img,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.store, size: 50, color: Colors.orange),
                  title: Text(
                    shopModel.shopName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopModel.location,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 5),
                          Text('4.5', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    // Khi người dùng bấm vào shop, điều hướng đến ChatScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(buyer: buyer, shop: shopModel), // Truyền buyer và shopModel vào ChatScreen
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
