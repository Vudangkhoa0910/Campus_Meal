import 'package:campus_catalogue/models/buyer_model.dart';
import 'package:campus_catalogue/models/shopModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting date and time

class ChatScreen extends StatefulWidget {
  final Buyer buyer; // Buyer object
  final ShopModel shop; // ShopModel object

  const ChatScreen({Key? key, required this.buyer, required this.shop}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final message = {
        'senderId': widget.buyer.user_id, // Buyer là người gửi
        'receiverId': widget.shop.shopID,  // Shop là người nhận
        'content': _messageController.text,
        'timestamp': Timestamp.now(),
      };

      try {
        await _firestore.collection('chats').add(message);
        _messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _getMessages() {
    return _firestore.collection('chats').orderBy('timestamp', descending: false).snapshots().map((snapshot) {
      return snapshot.docs;
    });
  }

  // Format timestamp to readable date and time
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.shop.shopName}'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: _getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No messages found.'));
                }

                final messages = snapshot.data!;

                // Ensure that the list is scrolled to the bottom
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data();
                    final isSender = messageData['senderId'] == widget.buyer.user_id;
                    final messageTimestamp = messageData['timestamp'] as Timestamp;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                      child: Align(
                        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSender ? Colors.orange[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Column(
                            crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                messageData['content'],
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(height: 5),
                              Text(
                                _formatTimestamp(messageTimestamp), // Display timestamp
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                              SizedBox(height: 5),
                              Text(
                                isSender ? widget.buyer.name : widget.shop.shopName,
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.orangeAccent, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.orange),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
