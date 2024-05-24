import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uispeed_grocery_shop/page/detail_page.dart';
import 'package:uispeed_grocery_shop/service/converter.dart';
import 'package:uispeed_grocery_shop/service/firebase_service.dart';

User? currentUser;

class CartPage extends StatefulWidget {
  final String userId;

  const CartPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _getUser();
    getProductsTotalPrice();
  }

  Future<void> getProductsTotalPrice() async {
    List<Map<String, dynamic>> products = [];
    int totalPrice = 0; // Inisialisasi total harga
    products = await fetchProductsFromFirestore(currentUser!.uid);
    for (Map<String, dynamic> product in products) {
      int price = await getProductTotalPrice(product['productId'], product);
      totalPrice += price; // Tambahkan harga produk ke total harga
    }

    // Set total harga ke state
    setState(() {
      this.totalPrice = totalPrice;
    });
  }

  Future<List<Map<String, dynamic>>> fetchProductsFromFirestore(
      String userId) async {
    try {
      // Lakukan pengambilan data produk dari Firestore
      DocumentSnapshot<Map<String, dynamic>> cartSnapshot =
          await FirebaseFirestore.instance
              .collection('carts')
              .doc(userId)
              .get();

      if (cartSnapshot.exists) {
        // Jika data keranjang ditemukan, ambil daftar produk dari keranjang
        Map<String, dynamic> cartData = cartSnapshot.data()!;
        List<Map<String, dynamic>> products =
            List<Map<String, dynamic>>.from(cartData['cart']);
        return products;
      } else {
        // Jika data keranjang tidak ditemukan, kembalikan list kosong
        return [];
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi
      print('Error fetching products: $e');
      throw e;
    }
  }

  Future<void> _getUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<Widget> _buildCartCard(
      Map<String, dynamic> product, BuildContext context) async {
    Map<String, dynamic> doc = await getProduct(product['productId']);
    String image = await getProductImage(product['productId']);
    int price = await getProductPrice(product['productId']);
    int quantity = product['quantity']!.toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return DetailPage(food: doc);
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
                      child: networkImage(image ?? "", 100, 100))),
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
                        product['productName'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Rp${priceConverter(price) ?? 0}',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await removeItemFromCart(
                              product['productId'], currentUser!);
                          await getProductsTotalPrice();
                        },
                        icon: const Icon(
                          Icons.disabled_by_default,
                          color: Color(0xFF00541A),
                          size: 28,
                        ),
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await removeFromCart(
                                  product['productId'], currentUser!);
                              await getProductsTotalPrice();
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon((CupertinoIcons.minus)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              product['quantity']!.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await addToCart(product['productId'],
                                  product['productName'], currentUser!);
                              await getProductsTotalPrice();
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon((CupertinoIcons.plus)),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang Belanja'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('carts')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Keranjang kamu kosong.'));
          }

          // Ambil data produk dari keranjang
          Map<String, dynamic> cartData =
              snapshot.data!.data()! as Map<String, dynamic>;
          List<Map<String, dynamic>> products =
              List<Map<String, dynamic>>.from(cartData['cart']);
          // Tampilkan daftar produk dalam keranjang
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> product = products[index];
                      return FutureBuilder<Widget>(
                        future: _buildCartCard(product, context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                                height: 100,
                                child: Center(
                                    child: CircularProgressIndicator(
                                  color: Color(0xFF00541A),
                                ))); // Show loading indicator while fetching card
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return snapshot.data!;
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery fee:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00541A),
                          ),
                        ),
                        Text(
                          '\ Rp30,000',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00541A),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sub-Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00541A),
                          ),
                        ),
                        Text(
                          priceConverter(totalPrice),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00541A),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF00541A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\ Rp70,000',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Check Out',
                          style: TextStyle(
                            color: Color(0xFF00541A),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<int> getProductPrice(String productId) async {
  // Mengambil referensi dokumen dari koleksi "products" dengan productId tertentu
  DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .get();

  // Memeriksa apakah dokumen ditemukan
  if (productSnapshot.exists) {
    // Mengambil harga dari properti 'price' dalam dokumen
    int price = productSnapshot['price'];
    return price;
  } else {
    // Dokumen tidak ditemukan
    throw Exception('Product with ID $productId not found');
  }
}

Future<String> getProductImage(String productId) async {
  // Mengambil referensi dokumen dari koleksi "products" dengan productId tertentu
  DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .get();

  // Memeriksa apakah dokumen ditemukan
  if (productSnapshot.exists) {
    // Mengambil harga dari properti 'image_url' dalam dokumen
    String image = productSnapshot['image_url'];
    return image;
  } else {
    // Dokumen tidak ditemukan
    throw Exception('Product with ID $productId not found');
  }
}

Future<Map<String, dynamic>> getProduct(String productId) async {
  // Mengambil referensi dokumen dari koleksi "products" dengan productId tertentu
  DocumentSnapshot<Map<String, dynamic>> productSnapshot =
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

  // Memeriksa apakah dokumen ditemukan
  if (productSnapshot.exists) {
    // Mengembalikan data produk dalam bentuk Map<String, dynamic>
    return productSnapshot.data()!;
  } else {
    // Dokumen tidak ditemukan
    throw Exception('Product with ID $productId not found');
  }
}

Future<int> getProductTotalPrice(
    String productId, Map<String, dynamic> product) async {
  int price = await getProductPrice(productId);
  int quantitiy = product['quantity'];
  return price * quantitiy;
}
