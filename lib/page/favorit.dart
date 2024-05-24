import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uispeed_grocery_shop/page/detail_page.dart';
import 'package:uispeed_grocery_shop/service/converter.dart';
import 'package:uispeed_grocery_shop/service/firebase_service.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  User? currentUser;
  List<String> favoriteProductIds = [];
  List<Map<String, dynamic>> favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        favoriteProductIds = List<String>.from(userDoc['favorites'] ?? []);
        await _loadFavoriteProducts();
      }
    }
  }

  Future<void> _loadFavoriteProducts() async {
    List<Map<String, dynamic>> products = [];
    for (String productId in favoriteProductIds) {
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productDoc.exists) {
        products.add(productDoc.data() as Map<String, dynamic>);
      }
    }
    setState(() {
      favoriteProducts = products;
    });
  }

  Future<void> _toggleFavorite(String productId) async {
    if (favoriteProductIds.contains(productId)) {
      setState(() {
        favoriteProductIds.remove(productId);
      });
    } else {
      setState(() {
        favoriteProductIds.add(productId);
      });
    }

    // Update the favorite list in Firestore
    await FirebaseFirestore.instance
        .collection('favorites')
        .doc(currentUser!.uid)
        .set({'favorites': favoriteProductIds});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00541A),
        title: const Text(
          'Favorit',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: favoriteProducts.isEmpty
          ? const Center(child: Text('Anda belum menambahkan favorit'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> product = favoriteProducts[index];
                return _buildFavoriteCard(product);
              },
            ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> product) {
    String productId = product['id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return DetailPage(food: product);
          }));
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                      width: 100,
                      height: 100,
                      child: networkImage(product['image_url']!, 100, 100))),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Rp${priceConverter(product['price'])}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00541A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: IconButton(
                    icon: Icon(
                      favoriteProductIds.contains(productId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: const Color(0xFF00541A),
                    ),
                    onPressed: () {
                      _toggleFavorite(productId);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
