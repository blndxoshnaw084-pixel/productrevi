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
      title: 'Cosmetic Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomePage(),
    );
  }
}

// 1. Simple HomePage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Simple product list
  final List<Map<String, String>> products = const [
    {'name': 'Night Cream', 'brand': 'Loreal', 'img': 'https://picsum.photos/seed/cream/100'},
    {'name': 'Lipstick', 'brand': 'MAC', 'img': 'https://picsum.photos/seed/lip/100'},
    {'name': 'Sunscreen', 'brand': 'Vichy', 'img': 'https://picsum.photos/seed/sun/100'},
    {'name': 'Face Wash', 'brand': 'CleanClear', 'img': 'https://picsum.photos/seed/wash/100'},
    {'name': 'Hair Serum', 'brand': 'Ordinary', 'img': 'https://picsum.photos/seed/hair/100'},
    {'name': 'Body Mist', 'brand': 'Victoria', 'img': 'https://picsum.photos/seed/body/100'},
    {'name': 'Foundation', 'brand': 'FitMe', 'img': 'https://picsum.photos/seed/found/100'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cosmetic Reviews', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, i) {
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(products[i]['img']!, width: 50, height: 50),
                    title: Text(products[i]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(products[i]['brand']!),
                    trailing: const Icon(Icons.comment, color: Color(0xFF1A237E)),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => ReviewDialog(productName: products[i]['name']!),
                    ),
                  ),
                );
              },
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(15),
            color: const Color(0xFF1A237E),
            width: double.infinity,
            child: const Text(
              'Developed by: Blnd Abdulla', 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

// 2. Simple Dialog for Reviews
class ReviewDialog extends StatefulWidget {
  final String productName;
  const ReviewDialog({super.key, required this.productName});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int stars = 5;
  TextEditingController comment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.productName),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rating system
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                icon: Icon(index < stars ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
                onPressed: () => setState(() => stars = index + 1),
              )),
            ),
            TextField(
              controller: comment,
              decoration: const InputDecoration(hintText: 'Write a comment...'),
            ),
            const SizedBox(height: 20),
            
            // Show old reviews from Firebase
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Past Reviews:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 120, // Fixed height so it doesn't break
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('reviews')
                    .where('product', isEqualTo: widget.productName).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return const Text('Loading...');
                  if (snapshot.data!.docs.isEmpty) return const Text('No reviews yet');
                  
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((doc) {
                      return Text('⭐ ${doc['stars']} - ${doc['comment']}');
                    }).toList(),
                  );
                },
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Close')
        ),
        ElevatedButton(
          onPressed: () {
            // Save to Firebase
            FirebaseFirestore.instance.collection('reviews').add({
              'product': widget.productName,
              'stars': stars,
              'comment': comment.text,
            });
            Navigator.pop(context);
          }, 
          child: const Text('Save')
        )
      ],
    );
  }
}