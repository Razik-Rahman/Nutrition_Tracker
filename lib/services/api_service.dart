import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class ApiService {
  // Use 127.0.0.1 for Windows/iOS testing, use 10.0.2.2 if testing on an Android Emulator
  static const String baseUrl = 'http://127.0.0.1:5000/api/foods';

  Future<List<FoodItem>> getFoods() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => FoodItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load foods');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }

  Future<FoodItem> addFood(FoodItem food) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(food.toJson()),
      );
      if (response.statusCode == 201) {
        return FoodItem.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to save food');
      }
    } catch (e) {
      throw Exception('Error saving food: $e');
    }
  }

  Future<void> deleteFood(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete food');
      }
    } catch (e) {
      throw Exception('Error deleting food: $e');
    }
  }
}
