import 'package:flutter/material.dart';

class NtfUserPage extends StatefulWidget {
  const NtfUserPage({super.key});

  @override
  State<NtfUserPage> createState() => _NtfUserPageState();
}

class _NtfUserPageState extends State<NtfUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Notifications"),
      ),
    );
  }
}
