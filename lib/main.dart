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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// --------------------------------
// زانیاری بەرهەمەکان
// --------------------------------
class Product {
  final String name;
  final String brand;
  final String imageUrl;

  const Product({
    required this.name,
    required this.brand,
    required this.imageUrl,
  });
}

const List<Product> products = [
  Product(
    name: 'Night Repair Cream',
    brand: 'Loreal',
    imageUrl: 'https://picsum.photos/seed/cream/200',
  ),
  Product(
    name: 'Matte Lipstick',
    brand: 'MAC',
    imageUrl: 'https://picsum.photos/seed/lipstick/200',
  ),
  Product(
    name: 'Sunscreen SPF 50',
    brand: 'Vichy',
    imageUrl: 'https://picsum.photos/seed/sunscreen/200',
  ),
  Product(
    name: 'Face Wash',
    brand: 'CleanClear',
    imageUrl: 'https://picsum.photos/seed/facewash/200',
  ),
  Product(
    name: 'Hair Serum',
    brand: 'Ordinary',
    imageUrl: 'https://picsum.photos/seed/hairserum/200',
  ),
  Product(
    name: 'Body Mist',
    brand: 'Victoria',
    imageUrl: 'https://picsum.photos/seed/bodymist/200',
  ),
  Product(
    name: 'Foundation',
    brand: 'FitMe',
    imageUrl: 'https://picsum.photos/seed/foundation/200',
  ),
];

// --------------------------------
// پەڕەی سەرەکی
// --------------------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: const Text(
          'Cosmetic Store',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
          ),
          // footer
          Container(
            color: const Color(0xFF1A237E),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: const Center(
              child: Text(
                'Developed by: Blnd Abdulla',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------
// کارتی بەرهەم
// --------------------------------
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openReviewDialog(context, product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // وێنەی بەرهەم
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: const Color(0xFFE8EAF6),
                    child: const Icon(Icons.image_not_supported,
                        color: Color(0xFF1A237E)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // ناو و براند
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.brand,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    // ستێرەکان (نمایش تەنها)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('reviews')
                          .where('product_name', isEqualTo: product.name)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Text('No reviews yet',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey));
                        }

                        // ناوەندی ستێرەکان
                        double avg = snapshot.data!.docs
                                .map((d) =>
                                    (d['stars'] as num).toDouble())
                                .reduce((a, b) => a + b) /
                            snapshot.data!.docs.length;

                        return Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < avg.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${snapshot.data!.docs.length})',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------
  // دیالۆگی ریڤیو
  // --------------------------------
  void _openReviewDialog(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReviewSheet(product: product),
    );
  }
}

// --------------------------------
// شیتی ریڤیو
// --------------------------------
class ReviewSheet extends StatefulWidget {
  final Product product;

  const ReviewSheet({super.key, required this.product});

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  int selectedStars = 0;
  final TextEditingController commentController = TextEditingController();
  bool isSaving = false;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _saveReview() async {
    if (selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تکایە ستێرە هەڵبژێرە!')),
      );
      return;
    }

    setState(() => isSaving = true);

    await FirebaseFirestore.instance.collection('reviews').add({
      'product_name': widget.product.name,
      'comment': commentController.text.trim(),
      'stars': selectedStars,
      'time': DateTime.now(),
    });

    setState(() => isSaving = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ریڤیوەکەت هێنرایەوە، سپاس!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // کیبۆردی پێوندی نەدات بە محتوا
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // هێڵی سەرەوە
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),

          // ناو و براندی بەرهەم
          Text(
            widget.product.name,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.product.brand,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // ستێرەکان
          const Text('رەیتینگ بدە:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => selectedStars = i + 1),
                child: Icon(
                  i < selectedStars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // کۆمێنت
          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'رای خۆت بنووسە...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
            ),
          ),
          const SizedBox(height: 16),

          // دوگمەی تۆمارکردن
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isSaving ? null : _saveReview,
              child: isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'تۆمارکردن',
                      style:
                          TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // ریڤیوە کۆنەکان
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('ریڤیوە پێشووەکان:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('product_name',
                      isEqualTo: widget.product.name)
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('هیچ ریڤیویەک نییە هێشتا.'));
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((doc) {
                    int stars = doc['stars'] ?? 0;
                    String comment = doc['comment'] ?? '';
                    return ListTile(
                      dense: true,
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < stars
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          ),
                        ),
                      ),
                      title: Text(
                        comment.isEmpty ? '(کۆمێنتی نییە)' : comment,
                        style: const TextStyle(fontSize: 13),
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
