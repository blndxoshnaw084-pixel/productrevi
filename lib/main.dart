import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmetic Review App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Simple list of products
  final List<Map<String, dynamic>> products = [
    {'name': 'Face Cream', 'brand': 'SoftSkin', 'rating': 4.5},
    {'name': 'Matte Lipstick', 'brand': 'RedVibe', 'rating': 4.0},
    {'name': 'Sunblock SPF50', 'brand': 'SunGuard', 'rating': 4.8},
    {'name': 'Shampoo', 'brand': 'HairCare', 'rating': 4.2},
    {'name': 'Mascara', 'brand': 'LongLash', 'rating': 4.7},
    {'name': 'Body Lotion', 'brand': 'DailyMoist', 'rating': 4.3},
    {'name': 'Perfume', 'brand': 'BlueNight', 'rating': 4.9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosmetic Reviews'),
        backgroundColor: Colors.pink[100],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.auto_awesome, color: Colors.pink),
                    title: Text(products[index]['name']),
                    subtitle: Text('Brand: ${products[index]['brand']}'),
                    trailing: Text('⭐ ${products[index]['rating']}'),
                    onTap: () {
                      _showReviewDialog(products[index]['name']);
                    },
                  ),
                );
              },
            ),
          ),
          // Footer with your name
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            width: double.infinity,
            child: const Text(
              'Created by: Blnd Abdulla',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Simple dialog to add a review
  void _showReviewDialog(String productName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Review for $productName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(hintText: 'Write your comment here'),
              ),
              const SizedBox(height: 10),
              const Text('Rate this product (1-5):'),
              Slider(value: 4, min: 1, max: 5, onChanged: (v) {}),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you for your review!')),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}