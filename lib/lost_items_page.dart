import 'package:flutter/material.dart';

class LostItemsPage extends StatefulWidget {
  @override
  _LostItemsPageState createState() => _LostItemsPageState();
}

class _LostItemsPageState extends State<LostItemsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> lostItems = []; // Initially empty list
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(lostItems);
  }

  void _searchItems(String query) {
    setState(() {
      filteredItems = lostItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lost Items"),
        backgroundColor: Color(0xFF075E54), // WhatsApp Green
      ),
      backgroundColor: Color(0xFFECE5DD), // WhatsApp background color
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchItems,
                decoration: InputDecoration(
                  hintText: "Search lost items...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      "No lost items available",
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          filteredItems[index],
                          style: TextStyle(color: Colors.black),
                        ),
                        leading: Icon(Icons.report_gmailerrorred, color: Colors.red),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}