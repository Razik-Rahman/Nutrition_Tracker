import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const FoodListApp());
}

class FoodListApp extends StatelessWidget {
  const FoodListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
