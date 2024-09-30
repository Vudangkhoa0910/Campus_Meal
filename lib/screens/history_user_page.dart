import 'package:flutter/material.dart';

class HistoryPageUser extends StatefulWidget {
  const HistoryPageUser({super.key});

  @override
  State<HistoryPageUser> createState() => _HistoryPageUserState();
}

class _HistoryPageUserState extends State<HistoryPageUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("History"),
      ),
    );
  }
}
