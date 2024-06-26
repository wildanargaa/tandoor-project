import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uispeed_grocery_shop/model/food.dart';
import 'package:uispeed_grocery_shop/page/detail_page.dart';
import 'package:uispeed_grocery_shop/page/favorit.dart';
import 'package:uispeed_grocery_shop/page/profil.dart';
import 'package:uispeed_grocery_shop/providers/user_provider.dart';
import 'package:uispeed_grocery_shop/service/converter.dart';
import 'package:uispeed_grocery_shop/service/firebase_service.dart';

import 'bottomCart.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  TextEditingController searchController = TextEditingController();
  String searchTerm = '';
  int indexCategory = 0;
  Widget nama = const Text(
    "selamat datang",
    style: TextStyle(
      color: Color(0xFF00541A),
      fontWeight: FontWeight.w500,
      fontSize: 18,
    ),
  );
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

  Widget buildProductsCard(Map<String, dynamic> food, BuildContext context) {
    String productId = food['id'];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailPage(
                    food: food,
                  )),
        ).then((value) {
          // Memeriksa nilai yang dikembalikan dari SecondScreen
          _loadFavorites();
        });
      },
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(120),
                      child: SizedBox(
                          width: 120,
                          height: 120,
                          child: networkImage(food['image_url']!, 120, 120))),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    food['name'] ?? 'No Name',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        food['conversion'] ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        food['rating']?.toString() ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Rp${priceConverter(food['price']!)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
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
            Align(
              alignment: Alignment.bottomRight,
              child: Material(
                color: const Color(0xFF00541A),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: InkWell(
                  onTap: () async {
                    await addToCart(productId, food['name'], currentUser!);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget foodGrid(String searchTerm) {
    return StreamBuilder<QuerySnapshot>(
      stream: (searchTerm == "")
          ? FirebaseFirestore.instance.collection('products').snapshots()
          : FirebaseFirestore.instance
              .collection('products')
              .where('name', isGreaterThanOrEqualTo: searchTerm)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No Data Found'));
        }

        final documents = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 270,
          ),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final data = documents[index].data() as Map<String, dynamic>;
            return buildProductsCard(data, context);
          },
        );
      },
    );
  }

  Widget search() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(8, 2, 6, 2),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00541A)),
                hintText: 'Search food',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: const Color(0xFF00541A),
        unselectedItemColor: const Color(0xFF13A941),
        currentIndex: indexCategory,
        onTap: (index) {
          setState(() {
            indexCategory = index;
            if (index == 1) {
              // Index 1 merupakan index dari item keranjang belanja
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CartPage(userId: currentUser!.uid)));
            }
            if (index == 2) {
              // Index 1 merupakan index dari item keranjang belanja
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              ).then((value) {
                // Memeriksa nilai yang dikembalikan dari SecondScreen

                setState(() {
                  // Memperbarui pesan dengan nilai yang dikembalikan
                  _loadFavorites();
                });
              });
            }
            if (index == 3) {
              // Index 1 merupakan index dari item keranjang belanja
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Person'),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          header(),
          const SizedBox(height: 10),
          title(nama),
          const SizedBox(height: 20),
          search(),
          //const SizedBox(height: 20),
          //categories(),
          const SizedBox(height: 10),
          foodGrid(searchTerm),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'asset/HP_LogoTandoor.png',
                  fit: BoxFit.cover,
                  width: 28,
                  height: 28,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Tandoor', style: TextStyle(fontSize: 18)),
            ],
          ),
          const Spacer(),
          Material(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child:
                    const Icon(Icons.notifications, color: Color(0xFF00541A)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget title(Widget nama) {
    var userData = ref.watch(userProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hi, ${userData['name']}',
                style: const TextStyle(
                  color: Color(0xFF00541A),
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const Text(
            'Temukan produk Anda',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget categories() {
    List list = ['Beranda', 'Promo', 'Produk'];
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 40,
        child: Center(
          child: ListView.builder(
            itemCount: list.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Center(
                child: GestureDetector(
                  onTap: () {
                    indexCategory = index;
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      index == 0 ? 16 : 16,
                      0,
                      index == list.length - 1 ? 16 : 16,
                      0,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      list[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        color: indexCategory == index
                            ? const Color(0xFF00541A)
                            : Colors.grey,
                        fontWeight:
                            indexCategory == index ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget gridFood() {
    return GridView.builder(
      itemCount: dummyFoods.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 270,
      ),
      itemBuilder: (context, index) {
        Food food = dummyFoods[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Container();
            }));
          },
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(120),
                        child: Image.asset(
                          food.image,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        food.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            food.cookingTime,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Spacer(),
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            food.rate.toString(),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Rp${food.price}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                      onTap: () async {
                        favorites.add("PD1");
                        User? loggedInUser =
                            await AuthService().getCurrentUser();
                        await updateProperty('favorites', loggedInUser!.uid,
                            'favorites', favorites);
                      },
                      child: const Icon(Icons.favorite_border,
                          color: Colors.grey)),
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Material(
                    color: Color(0xFF00541A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: InkWell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
