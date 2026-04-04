import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      title: 'Cosmetic Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        useMaterial3: true,
      ),
      home: const CosmeticHome(),
    );
  }
}

class CosmeticHome extends StatefulWidget {
  const CosmeticHome({super.key});

  @override
  State<CosmeticHome> createState() => _CosmeticHomeState();
}

class _CosmeticHomeState extends State<CosmeticHome> {
  final List<Map<String, dynamic>> items = [
    {'name': 'Night Repair Cream', 'brand': 'Loreal', 'stars': 5},
    {'name': 'Matte Lipstick', 'brand': 'MAC', 'stars': 4},
    {'name': 'Sunscreen SPF 50', 'brand': 'Vichy', 'stars': 5},
    {'name': 'Face Wash', 'brand': 'CleanClear', 'stars': 3},
    {'name': 'Hair Serum', 'brand': 'Ordinary', 'stars': 4},
    {'name': 'Body Mist', 'brand': 'Victoria', 'stars': 5},
    {'name': 'Foundation', 'brand': 'FitMe', 'stars': 4},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosmetic Product Reviews', style: TextStyle(fontSize: 22)),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: const Icon(Icons.shopping_bag, color: Color(0xFF1A237E), size: 30),
                    title: Text(items[index]['name'], 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('Brand: ${items[index]['brand']}', 
                        style: const TextStyle(fontSize: 15)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _openReview(items[index]['name']),
                  ),
                );
              },
            ),
          ),
          Container(
            color: const Color(0xFF1A237E),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Developed by: Blnd Abdulla',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera_alt, color: Colors.white70, size: 22),
                    SizedBox(width: 20),
                    Icon(Icons.facebook, color: Colors.white70, size: 22),
                    SizedBox(width: 20),
                    Icon(Icons.alternate_email, color: Colors.white70, size: 22),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openReview(String title) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate $title', style: const TextStyle(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.amber)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
            onPressed: () async {
              // ناردنی زانیارییەکان بۆ ناو Firestore Database
              await FirebaseFirestore.instance.collection('reviews').add({
                'product_name': title,
                'comment': commentController.text,
                'time': DateTime.now(),
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review Saved successfully!')),
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}