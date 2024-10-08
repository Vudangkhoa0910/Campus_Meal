import 'package:flutter/material.dart';

class NtfUserPage extends StatefulWidget {
  const NtfUserPage({super.key});

  @override
  State<NtfUserPage> createState() => NtfUserPageState();
}

class NtfUserPageState extends State<NtfUserPage> {
  // Dữ liệu giả để mô phỏng thông báo
  final List<Map<String, String>> notifications = [
    {
      "title": "Voucher giảm giá 20%",
      "description": "Sử dụng mã: SAVE20 cho đơn hàng tiếp theo.",
      "date": "01/10/2024",
    },
    {
      "title": "Sự kiện ẩm thực",
      "description": "Tham gia sự kiện ẩm thực vào thứ 7 này!",
      "date": "02/10/2024",
    },
    {
      "title": "Đơn hàng của bạn đã được xác nhận",
      "description": "Đơn hàng #1234 sẽ được giao trong 30 phút.",
      "date": "01/10/2024",
    },
    {
      "title": "Thông tin mới về ứng dụng",
      "description": "Cập nhật phiên bản mới với nhiều tính năng hấp dẫn.",
      "date": "30/09/2024",
    },
    {
      "title": "Khuyến mãi đặc biệt",
      "description": "Giảm giá 15% cho đơn hàng từ 200.000đ.",
      "date": "03/10/2024",
    },
    {
      "title": "Hỗ trợ khách hàng",
      "description": "Bạn có thể liên hệ với chúng tôi qua số hotline.",
      "date": "29/09/2024",
    },
    {
      "title": "Cập nhật món ăn mới",
      "description": "Chúng tôi đã thêm món sushi mới vào menu.",
      "date": "28/09/2024",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotificationCard(
            title: notifications[index]["title"]!,
            description: notifications[index]["description"]!,
            date: notifications[index]["date"]!,
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle, // Biểu tượng tích xanh
              color: Colors.green,
              size: 24, // Kích thước biểu tượng
            ),
            const SizedBox(width: 10), // Khoảng cách giữa biểu tượng và tiêu đề
            Expanded(
              // Để tiêu đề và mô tả chiếm toàn bộ không gian còn lại
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 145, 0),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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
