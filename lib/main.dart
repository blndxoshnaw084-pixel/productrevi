import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<String> products = const [
    'iPhone 15 Pro Max',
    'MacBook Pro M3',
    'Sony Wireless Headphones',
    'Samsung Galaxy Watch',
    'Dell 4K Monitor',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Review App', style: TextStyle(fontSize: 26)), 
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: const Icon(Icons.devices, color: Color(0xFF1A237E), size: 35),
                    title: Text(products[index], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), // فۆنتی ٢٢
                    trailing: const Icon(Icons.star_rate, color: Colors.amber, size: 30),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewPage(productName: products[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // Footer Section with Icons
          Container(
            width: double.infinity,
            color: const Color(0xFF1A237E),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Text(
                  'Developed by: Blnd Abdulla',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera_alt, color: Colors.white70, size: 28), // Instagram
                    SizedBox(width: 25),
                    Icon(Icons.facebook, color: Colors.white70, size: 28), // Facebook
                    SizedBox(width: 25),
                    Icon(Icons.phone, color: Colors.white70, size: 28), // Contact
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewPage extends StatefulWidget {
  final String productName;
  const ReviewPage({super.key, required this.productName});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController commentController = TextEditingController();
  int currentRating = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName, style: const TextStyle(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Select Rating:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < currentRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 45, // سایزی گەورەی ستێرەکان
                    ),
                    onPressed: () => setState(() => currentRating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 30),
              const Text('2. Write Review:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: commentController,
                style: const TextStyle(fontSize: 20),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter your feedback here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: () async {
                    if (commentController.text.isNotEmpty) {
                      // Save data to Firebase
                      await FirebaseFirestore.instance.collection('reviews').add({
                        'product': widget.productName,
                        'comment': commentController.text,
                        'rating': currentRating,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      
                      // Show success message and go back
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thank you for your review!', style: TextStyle(fontSize: 18))),
                        );
                        Navigator.pop(context); // Automatically returns to Home
                      }
                    }
                  },
                  child: const Text('Submit Review', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}