import 'package:flutter/material.dart';
import '../data/mock_food_data.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
import 'food_details_page.dart';
import 'add_food_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<FoodItem> _allFoods = [];
  List<FoodItem> _filteredFoods = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    try {
      final foods = await _apiService.getFoods();
      setState(() {
        _allFoods = foods;
        _filteredFoods = _allFoods;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to mock data if the backend is not running
      setState(() {
        _allFoods = List.from(mockFoodData);
        _filteredFoods = _allFoods;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not connect to backend. Showing offline mock data.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _filterFoods() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredFoods = _allFoods.where((food) {
        final matchesQuery = food.name.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == 'All' || food.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _navigateAndAddFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFoodPage()),
    );

    if (result != null && result is FoodItem) {
      setState(() => _isLoading = true);
      try {
        final savedFood = await _apiService.addFood(result);
        setState(() {
          _allFoods.insert(0, savedFood);
          _filterFoods();
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${savedFood.name} added successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save food to database.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Nutrition Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndAddFood,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _filterFoods(),
                      decoration: InputDecoration(
                        hintText: 'Search for food...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.blueAccent),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterFoods();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                ),

                // Category Filters (Horizontal Scroll)
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: foodCategories.length,
                    itemBuilder: (context, index) {
                      final category = foodCategories[index];
                      final isSelected = category == _selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            _filterFoods();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blueAccent : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              if (!isSelected)
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // List of Foods
                Expanded(
                  child: _filteredFoods.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No food found!', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredFoods.length,
                          itemBuilder: (context, index) {
                            final food = _filteredFoods[index];
                            return Dismissible(
                              key: ValueKey(food.id ?? food.hashCode.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24.0),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 32),
                              ),
                              onDismissed: (direction) async {
                                final foodId = food.id;
                                setState(() {
                                  _allFoods.remove(food);
                                  _filterFoods();
                                });
                                
                                if (foodId != null) {
                                  try {
                                    await _apiService.deleteFood(foodId);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${food.name} deleted from database'),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    // If deletion fails, add it back
                                    setState(() {
                                      _allFoods.insert(index, food);
                                      _filterFoods();
                                    });
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to delete from database'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  // Was a mock data item without an ID
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${food.name} deleted locally')),
                                    );
                                  }
                                }
                              },
                              child: FoodCard(food: food),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final FoodItem food;

  const FoodCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailsPage(food: food),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      food.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D3142)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      food.category,
                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNutritionInfo(icon: Icons.scale_rounded, value: '${food.gram}g', label: 'Weight', color: Colors.blueAccent),
                  _buildNutritionInfo(icon: Icons.fitness_center_rounded, value: '${food.protein}g', label: 'Protein', color: Colors.redAccent),
                  _buildNutritionInfo(icon: Icons.grass_rounded, value: '${food.fibre}g', label: 'Fibre', color: Colors.green),
                  _buildNutritionInfo(icon: Icons.local_fire_department_rounded, value: '${food.calories.toInt()}', label: 'kCal', color: Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionInfo({required IconData icon, required String value, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
      ],
    );
  }
}
