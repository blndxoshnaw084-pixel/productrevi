import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // ئەم فایلە پێشتر دروست بوو لە هەنگاوی پێشوو

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // دەستپێکردنی فایەربەیس بە کۆنفیدیورە نوێیەکەت
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
      debugShowCheckedModeBanner: false,
      title: 'Product Review',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const ProductReviewScreen(),
    );
  }
}

class ProductReviewScreen extends StatefulWidget {
  const ProductReviewScreen({super.key});

  @override
  State<ProductReviewScreen> createState() => _ProductReviewScreenState();
}

class _ProductReviewScreenState extends State<ProductReviewScreen> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference _reviews = FirebaseFirestore.instance.collection('reviews');

  // فەرمانی ناردنی هەڵسەنگاندن بۆ فایەربەیس
  void _sendReview() {
    if (_controller.text.trim().isNotEmpty) {
      _reviews.add({
        'text': _controller.text.trim(),
        'time': FieldValue.serverTimestamp(),
      });
      _controller.clear();
      FocusScope.of(context).unfocus(); // داخستنی کیبۆرد دوای ناردن
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('هەڵسەنگاندنی بەرهەم'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // بەشی نووسینی هەڵسەنگاندن
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'ڕای خۆت بنووسە...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _sendReview,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
          
          const Divider(),

          // نیشاندانی هەڵسەنگاندنەکان بە ڕاستەوخۆ (Stream)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _reviews.orderBy('time', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('هەڵەیەک ڕوویدا!'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(data['text'] ?? ''),
                        subtitle: Text(
                          data['time'] != null 
                          ? (data['time'] as Timestamp).toDate().toString().substring(0, 16)
                          : 'ئێستا',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}