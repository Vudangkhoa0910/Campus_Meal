import 'package:campus_catalogue/screens/chat_seller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:campus_catalogue/models/buyer_model.dart';

class BuyerSelectionScreen extends StatelessWidget {
  final ShopModel shop; // Nhận đối tượng ShopModel

  const BuyerSelectionScreen({Key? key, required this.shop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Buyer'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Buyer').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final buyers = snapshot.data!.docs;
          return ListView.builder(
            itemCount: buyers.length,
            itemBuilder: (context, index) {
              final buyerData = buyers[index].data() as Map<String, dynamic>;

              // Tạo đối tượng Buyer từ dữ liệu buyer
              final buyerModel = Buyer.fromMap(buyerData);

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
  leading: ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Image.asset(
      'assets/images/seller_type.png', // Đường dẫn tới ảnh local
      width: 60,
      height: 60,
      fit: BoxFit.cover,
    ),
  ),
  title: Text(
    buyerModel.name,
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.orange,
    ),
  ),
  subtitle: Text(
    buyerModel.email,
    style: TextStyle(color: Colors.grey[600]),
  ),
  onTap: () {
    // Khi người dùng bấm vào buyer, điều hướng đến ChatScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(buyer: buyerModel), // Truyền shop và buyer vào ChatScreen
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
