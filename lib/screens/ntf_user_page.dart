import 'package:campus_catalogue/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import Firestore

class NtfUserPage extends StatefulWidget {
  const NtfUserPage({super.key});

  @override
  State<NtfUserPage> createState() => NtfUserPageState();
}

class NtfUserPageState extends State<NtfUserPage> {
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final notificationsSnapshot =
        await FirebaseFirestore.instance.collection('notifications').get();

    // Chuyển đổi danh sách tài liệu thành danh sách bản đồ
    List<Map<String, dynamic>> notifications = notificationsSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // Sắp xếp theo trường 'date' dưới dạng chuỗi
    notifications.sort((a, b) {
      // Giả sử 'date' là chuỗi với định dạng 'HH:mm dd/MM/yyyy'
      DateTime dateA = DateFormat('HH:mm dd/MM/yyyy').parse(a['date']);
      DateTime dateB = DateFormat('HH:mm dd/MM/yyyy').parse(b['date']);
      return dateB.compareTo(dateA); // Sắp xếp theo thứ tự giảm dần
    });

    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications available'));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              bool isNew = false;
              DateTime notificationDate;

              try {
                // notificationDate =
                //     DateFormat('dd/MM/yyyy').parse(notification["date"]);
                // // isNew = DateTime.now().difference(notificationDate).inDays < 3;
                notificationDate =
                    DateFormat('HH:mm dd/MM/yyyy').parse(notification["date"]);

                // So sánh xem thông báo có mới hay không trong vòng 5 phút
                isNew =
                    DateTime.now().difference(notificationDate).inMinutes < 5;

                Duration difference =
                    DateTime.now().difference(notificationDate);
                print("Difference in minutes: ${difference.inMinutes}");
              } catch (e) {
                print('Error parsing date: ${notification["date"]}, error: $e');
                notificationDate = DateTime.now();
              }

              return NotificationCard(
                title: notification["title"] ?? 'No Title',
                description: notification["description"] ?? 'No Description',
                date: notification["date"] ?? 'Unknown Date',
                isNew: isNew,
              );
            },
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
  final bool isNew;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 250, 240, 211)!,
                const Color.fromARGB(255, 255, 233, 154)!
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.15),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 145, 0),
                        ),
                      ),
                    ),
                    // Badge "New"
                    if (isNew) // Kiểm tra nếu thông báo mới
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(
                  color: Colors.orange,
                  thickness: 1.2,
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 250, 227),
                              title: const Text(
                                'Notification Details',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold), // Màu tiêu đề
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment.center, // Căn giữa
                                children: [
                                  Text(
                                    'Date: $date',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black), // Màu văn bản
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Details: $description',
                                    textAlign: TextAlign
                                        .center, // Căn giữa cho văn bản
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Saved successfully!',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color.fromARGB(
                                            255, 59, 222, 5),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: const Text('Save'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Colors.orange, // Màu chữ nút đóng
                                  ),
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
