import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generative AI App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[100], // Light background
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      home: FoodChatScreen(),
    );
  }
}

class FoodChatScreen extends StatefulWidget {
  @override
  _FoodChatScreenState createState() => _FoodChatScreenState();
}

class _FoodChatScreenState extends State<FoodChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];
  final String geminiApiKey = 'AIzaSyAlm5c_M4ULC3qwKWz5VABu9WIAiitL4qg'; // Set API key directly

  @override
  void initState() {
    super.initState();
  }

  void _sendMessage(String message) {
    if (message.isEmpty) return; // Prevent sending empty messages
    setState(() {
      _messages.add("You: $message");
      _messageController.clear();
    });
    _getResponseFromApi(message);
  }

  Future<void> _getResponseFromApi(String message) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminiApiKey,
      );

      final response = await model.generateContent([Content.text(message)]);
      // Ensure the response text is non-null
      setState(() {
        _messages.add(formatBotResponse(response.text ?? "Không có phản hồi.")); // Fallback if response.text is null
      });
    } catch (error) {
      setState(() {
        _messages.add("Bot: Lỗi trong quá trình kết nối: $error");
      });
    }
}

  String formatBotResponse(String response) {
  response = response.replaceAll(RegExp(r'\*+'), '').trim(); 
  
  return "🧑‍🍳 Bot:\n\n" + 
         response + "\n\n" + 
         "---\n" + 
         "Thank You !";
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'CAMPUS MEAL AI',
        style: TextStyle(
          fontSize: 22, 
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 255, 111, 0), 
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.orange,
              offset: Offset(1.0, 1.0), 
            ),
          ],
        ),
      ),
      centerTitle: true, 
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
      elevation: 4, 
    ),
    body: Container(
      decoration: BoxDecoration(
        color: Colors.grey[100], // Màu nền cho toàn bộ cửa sổ
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Border radius cho góc trên
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildChatBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(), 
          _buildSuggestions(), // Phần đề xuất
          SizedBox(height: 50),
        ],
      ),
    ),
  );
}

  Widget _buildChatBubble(String message) {
    bool isUserMessage = message.startsWith("You:");
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isUserMessage ? Colors.orange[200] : const Color.fromARGB(255, 255, 233, 201),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
    );
  }

  Widget _buildSuggestions() {
  final List<String> suggestions = [
    'Nấu phở',
    'Top 5 ngón ngon',
    'Ăn đâu Hà Nội',
    'Pasta',
    'Salad',
    'Kem',
  ];

  return Container(
    padding: const EdgeInsets.all(10.0),
    color: Colors.orange[100],
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: suggestions.map((item) {
          return GestureDetector(
            onTap: () => _sendMessage(item),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 166, 33),
                borderRadius: BorderRadius.circular(15), // Border radius cho phần đề xuất
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                item,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}

  Widget _buildMessageInput() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
        color:  Colors.orange[100],
        borderRadius: BorderRadius.circular(20), // Border radius cho ô nhập
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter questions...',
                border: InputBorder.none, 
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.orange),
            onPressed: () {
              _sendMessage(_messageController.text);
            },
          ),
        ],
      ),
    ),
  );
}
}
