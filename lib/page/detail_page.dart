import 'package:flutter/material.dart';
import '../model/food.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.food}) : super(key: key);
  final Food food;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00541A),
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
      minHeight: MediaQuery.of(context).size.height , // Set minimum tinggi container sama dengan tinggi layar
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
                    widget.food.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 34,
                    ),
                  ),
                  Text('Rp${widget.food.price}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00541A),
                      )),
                ],
              ),
            ),
            Material(
              color: Color(0xFF00541A),
              borderRadius: BorderRadius.circular(30),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        quantity -= 1;
                        setState(() {});
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
                    onPressed: () {
                      quantity += 1;
                      setState(() {});
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
              widget.food.rate.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.scale_rounded, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              widget.food.cookingTime,
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
          widget.food.description,
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
                child: Image.asset(
                  widget.food.image,
                  fit: BoxFit.cover,
                  width: 250,
                  height: 250,
                ),
              ),
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
            child: const BackButton(color: Colors.white),
          ),
          const Spacer(),
          Text(
            'Detail Produk',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: Colors.white,
                ),
          ),
          const Spacer(),
          Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.favorite_border, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget addToCartButton() {
    return Material(
      color: Color(0xFF00541A),
      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
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
