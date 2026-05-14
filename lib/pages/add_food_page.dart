import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../data/mock_food_data.dart'; // to get category list

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  
  String name = '';
  String description = '';
  String category = 'Protein'; // Default category
  double gram = 0;
  double protein = 0;
  double fibre = 0;
  double calories = 0;

  @override
  Widget build(BuildContext context) {
    // Exclude 'All' from dropdown
    final List<String> dropdownCategories = foodCategories.where((c) => c != 'All').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Add New Food', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nutritional Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField('Food Name', 'e.g., Apple', (value) => name = value, false),
              _buildDropdown('Category', dropdownCategories),
              _buildTextField('Description', 'Brief details about the food...', (value) => description = value, false, maxLines: 3),
              Row(
                children: [
                  Expanded(child: _buildTextField('Serving (g)', 'e.g., 100', (value) => gram = double.tryParse(value) ?? 0, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Calories', 'e.g., 52', (value) => calories = double.tryParse(value) ?? 0, true)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField('Protein (g)', 'e.g., 0.3', (value) => protein = double.tryParse(value) ?? 0, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Fibre (g)', 'e.g., 2.4', (value) => fibre = double.tryParse(value) ?? 0, true)),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newFood = FoodItem(
                      name: name,
                      description: description,
                      category: category,
                      gram: gram,
                      protein: protein,
                      fibre: fibre,
                      calories: calories,
                    );
                    Navigator.pop(context, newFood);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: const Text('Save Food', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: category,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: items.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() => category = newValue);
              }
            },
            onSaved: (newValue) {
              if (newValue != null) {
                category = newValue;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, Function(String) onSaved, bool isNumber, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              if (isNumber && double.tryParse(value) == null) {
                return 'Invalid number';
              }
              return null;
            },
            onSaved: (value) => onSaved(value!),
          ),
        ],
      ),
    );
  }
}
