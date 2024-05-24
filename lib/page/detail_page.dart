import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uispeed_grocery_shop/service/converter.dart';
import 'package:uispeed_grocery_shop/service/firebase_service.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.food}) : super(key: key);
  final Map<String, dynamic> food;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int quantity = 0;
  User? currentUser = FirebaseAuth.instance.currentUser;
  List<String> favoriteProductIds = [];
  List<Map<String, dynamic>> favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    fetchCartQuantity();
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

  Future<void> fetchCartQuantity() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot cartDoc = await FirebaseFirestore.instance
            .collection('carts')
            .doc(currentUser!.uid)
            .get();

        if (cartDoc.exists) {
          List<Map<String, dynamic>> cartItems = List.from(cartDoc['cart']);
          for (var item in cartItems) {
            if (item['productId'] == widget.food['id']) {
              setState(() {
                quantity = item['quantity'];
              });
              break;
            }
          }
        }
      } catch (e) {
        print('Error fetching cart quantity: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00541A),
      body: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 20),
              header(),
              const SizedBox(height: 20),
              image(),
              details(),
            ],
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: addToCartButton(),
          ),
        ],
      ),
    );
  }

  Container details() {
    return Container(
      color: Colors.white, // Warna latar belakang putih
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context)
            .size
            .height, // Set minimum tinggi container sama dengan tinggi layar
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.food['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 34,
                      ),
                    ),
                    Text('Rp${priceConverter(widget.food['price'])}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00541A),
                        )),
                  ],
                ),
              ),
              Material(
                color: const Color(0xFF00541A),
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        if (quantity > 1) {
                          await removeFromCart(widget.food['id'], currentUser!);
                          await fetchCartQuantity();
                        } else if (quantity == 1) {
                          await removeFromCart(widget.food['id'], currentUser!);
                          setState(() {
                            quantity = 0;
                          });
                        }
                      },
                      icon: const Icon(Icons.remove, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$quantity',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () async {
                        await addToCart(widget.food['id'], widget.food['name'],
                            currentUser!);
                        await fetchCartQuantity();
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                widget.food['rating'].toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.scale_rounded, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                widget.food['conversion'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Deskripsi Produk',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.food['description'],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  SizedBox image() {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
                borderRadius: BorderRadius.circular(250),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(250),
                  child: SizedBox(
                      width: 250,
                      height: 250,
                      child:
                          networkImage(widget.food['image_url']!, 250, 250))),
            ),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            child: BackButton(
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ),
          const Spacer(),
          Text(
            'Detail Produk',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                ),
          ),
          const Spacer(),
          Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                _toggleFavorite(widget.food['id']);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: Icon(
                    favoriteProductIds.contains(widget.food['id'])
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget addToCartButton() {
    return Material(
      color: const Color(0xFF00541A),
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: const Text(
            'Tambahkan ke keranjang',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
