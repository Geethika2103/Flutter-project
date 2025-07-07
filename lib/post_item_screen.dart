import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class PostItemScreen extends StatefulWidget {
  @override
  _PostItemScreenState createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  String? selectedCategory;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isUploading = false;

  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToSupabase(File imageFile) async {
    try {
      final String fileName = path.basename(imageFile.path);
      final storagePath = 'uploads/$fileName';
      final bytes = await imageFile.readAsBytes();
      await supabase.storage.from('images').uploadBinary(storagePath, bytes);
      return supabase.storage.from('images').getPublicUrl(storagePath);
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _postItem() async {
    if (_itemNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _contactInfoController.text.isEmpty ||
        selectedCategory == null ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    setState(() => _isUploading = true);
    
    try {
      final imageUrl = await _uploadImageToSupabase(_image!);
      if (imageUrl == null) throw Exception('Image upload failed');

      await supabase.from('items').insert({
        'name': _itemNameController.text,
        'description': _descriptionController.text,
        'contact': _contactInfoController.text,
        'category': selectedCategory,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item posted successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post item! Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post Item'), backgroundColor: Color(0xFF075E54)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_itemNameController, "Item Name", Icons.label),
            SizedBox(height: 12),
            _buildTextField(_descriptionController, "Description", Icons.description, maxLines: 3),
            SizedBox(height: 12),
            _buildUploadImageButton(),
            if (_image != null) Image.file(_image!, height: 200),
            SizedBox(height: 12),
            _buildTextField(_contactInfoController, "Contact Info", Icons.phone, inputType: TextInputType.phone),
            SizedBox(height: 12),
            _buildDropdown(),
            SizedBox(height: 20),
            _buildPostButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildUploadImageButton() {
    return OutlinedButton.icon(
      onPressed: _openCamera,
      icon: Icon(Icons.camera_alt, color: Colors.teal),
      label: Text("Upload image", style: TextStyle(color: Colors.teal)),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.teal),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      onChanged: (value) => setState(() => selectedCategory = value),
      items: ['Lost', 'Found', 'Trade'].map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
      decoration: InputDecoration(
        labelText: "Select Category",
        prefixIcon: Icon(Icons.category, color: Colors.teal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPostButton() {
    return ElevatedButton(
      onPressed: _isUploading ? null : _postItem,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _isUploading ? Colors.grey : Color(0xFF25D366),
      ),
      child: _isUploading ? CircularProgressIndicator(color: Colors.white) : Text("Post Item", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}