import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'post_item_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> lostItems = [];
  List<dynamic> foundItems = [];
  List<dynamic> tradeItems = [];
  String searchQuery = "";
  String selectedFilter = "All"; // Store selected filter option

  @override
  void initState() {
    super.initState();
    _fetchItems();

    supabase
        .from('items')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .listen((data) {
          if (mounted) {
            setState(() {
              _fetchItems();
            });
          }
        });
  }

  Future<void> _fetchItems() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('items')
          .select()
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          lostItems =
              response.where((item) => item['category'] == 'Lost').toList();
          foundItems =
              response.where((item) => item['category'] == 'Found').toList();
          tradeItems =
              response.where((item) => item['category'] == 'Trade').toList();
        });
      }
    } catch (error) {
      print('❌ Error fetching items: $error');
    }
  }

  Future<void> _markItemAsRead(Map<String, dynamic> item) async {
    try {
      await supabase
          .from('items')
          .update({'category': 'Found'}).match({'id': item['id']});
      _fetchItems(); // Refresh items
    } catch (error) {
      print('❌ Error marking item as read: $error');
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Filter Items",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildFilterOption("All", Icons.list),
              _buildFilterOption("Today", Icons.today),
              _buildFilterOption("This Week", Icons.calendar_view_week),
              _buildFilterOption("This Month", Icons.date_range),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String filter, IconData icon) {
    return ListTile(
      leading: Icon(icon,
          color: selectedFilter == filter ? Colors.blue : Colors.grey),
      title: Text(filter, style: TextStyle(fontSize: 16)),
      tileColor: selectedFilter == filter ? Colors.blue.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
        Navigator.pop(context); // Close bottom sheet
      },
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF075E54),
          title: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.white70),
                suffixIcon: searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            searchQuery = "";
                          });
                        },
                        child: Icon(Icons.close, color: Colors.white70),
                      )
                    : null,
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list, color: Colors.white),
              onPressed: _showFilterBottomSheet,
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatScreen()));
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _fetchItems();
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Lost Items'),
              Tab(text: 'Found Items'),
              Tab(text: 'Trade'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildItemList(lostItems, "No lost items yet. Post one now!",
                isLostTab: true),
            _buildItemList(foundItems, "No found items yet. Help someone out!"),
            _buildItemList(
                tradeItems, "No trade listings yet. Start trading now!"),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostItemScreen()),
            );
            if (result == true) {
              _fetchItems();
            }
          },
          label: Text('Post Item'),
          icon: Icon(Icons.add),
          backgroundColor: Color(0xFF25D366),
        ),
      ),
    );
  }

  Widget _buildItemList(List<dynamic> items, String emptyMessage,
      {bool isLostTab = false}) {
    final DateTime now = DateTime.now();

    final filteredItems = items.where((item) {
      final createdAt = DateTime.tryParse(item['created_at']) ?? now;
      final name = item['name']?.toString().toLowerCase() ?? "";
      final description = item['description']?.toString().toLowerCase() ?? "";

      bool matchesSearch =
          name.contains(searchQuery) || description.contains(searchQuery);

      if (selectedFilter == "Today") {
        return createdAt.year == now.year &&
            createdAt.month == now.month &&
            createdAt.day == now.day &&
            matchesSearch;
      } else if (selectedFilter == "This Week") {
        final oneWeekAgo = now.subtract(Duration(days: 7));
        return createdAt.isAfter(oneWeekAgo) && matchesSearch;
      } else if (selectedFilter == "This Month") {
        return createdAt.year == now.year &&
            createdAt.month == now.month &&
            matchesSearch;
      }
      return matchesSearch;
    }).toList();

    return filteredItems.isEmpty
        ? Center(
            child: Text(
              emptyMessage,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: ListTile(
                  title: Text(item['name'] ?? "No name",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['description'] ?? "No description"),
                  leading: item['image_url'] != null
                      ? GestureDetector(
                          onTap: () => _showImageDialog(item['image_url']),
                          child: Image.network(
                            item['image_url'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
                  trailing: isLostTab
                      ? ElevatedButton(
                          onPressed: () => _markItemAsRead(item),
                          child: Text("Mark as Read"),
                        )
                      : null,
                ),
              );
            },
          );
  }
}
