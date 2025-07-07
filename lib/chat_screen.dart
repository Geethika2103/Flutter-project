import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Color(0xFF075E54), // WhatsApp Green
      ),
      body: Container(
        color: Color(0xFFECE5DD), // WhatsApp chat background
        child: Center(
          child: Text(
            'No messages yet!',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          ),
        ),
      ),
    );
  }
}