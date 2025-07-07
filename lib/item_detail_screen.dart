import 'package:flutter/material.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  ItemDetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['name'] ?? 'Item Details'),
        backgroundColor: Color(0xFF075E54),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['image_url'] != null)
              Center(
                child: Image.network(
                  item['image_url'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Text(
              "Name: ${item['name'] ?? 'No name'}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Description: ${item['description'] ?? 'No description'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Category: ${item['category']}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Posted on: ${item['created_at']}",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
