import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uispeed_grocery_shop/model/food.dart';
import 'package:uispeed_grocery_shop/page/detail_page.dart';
import 'package:uispeed_grocery_shop/page/favorit.dart';
import 'package:uispeed_grocery_shop/page/profil.dart';
import 'package:uispeed_grocery_shop/providers/user_provider.dart';
import 'package:uispeed_grocery_shop/service/firebase_service.dart';

import 'bottomCart.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int indexCategory = 0;
  Widget nama = const Text(
    "selamat datang",
    style: TextStyle(
      color: Color(0xFF00541A),
      fontWeight: FontWeight.w500,
      fontSize: 18,
    ),
  );

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _checkAndHandleUserDocument();
  }

  Future<void> _checkAndHandleUserDocument() async {
    User? loggedInUser = await AuthService().getCurrentUser();
    // Panggil fungsi checkAndHandleDocument dengan user.uid
    await checkAndHandleDocument("favorites", loggedInUser!.uid,
        {"name": loggedInUser.email, "favorites": []});

    favorites = await getProperty('favorites', loggedInUser.uid, 'favorites');

    print(favorites);
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
                  context, MaterialPageRoute(builder: (_) => BottomCart()));
            }
            if (index == 2) {
              // Index 1 merupakan index dari item keranjang belanja
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => FavoritePage()));
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
          const SizedBox(height: 20),
          categories(),
          const SizedBox(height: 10),
          gridFood(),
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
              return DetailPage(food: food);
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
