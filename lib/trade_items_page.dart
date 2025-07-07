import 'package:flutter/material.dart';

class TradeItemsPage extends StatefulWidget {
  @override
  _TradeItemsPageState createState() => _TradeItemsPageState();
}

class _TradeItemsPageState extends State<TradeItemsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> tradeItems = []; // Initially empty list
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(tradeItems);
  }

  void _searchItems(String query) {
    setState(() {
      filteredItems = tradeItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trade Items"),
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
                  hintText: "Search trade items...",
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
                      "No trade items available",
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
                        leading: Icon(Icons.swap_horiz, color: Color(0xFF128C7E)), // WhatsApp green
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}