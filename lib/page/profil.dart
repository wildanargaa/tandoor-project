import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uispeed_grocery_shop/page/editprofile_page.dart';
import 'package:uispeed_grocery_shop/providers/user_provider.dart';
import 'package:uispeed_grocery_shop/service/firebase_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late DateTime _lastEditedDate;

  @override
  void initState() {
    super.initState();
    // Inisialisasi _lastEditedDate dengan tanggal saat ini
    _lastEditedDate = DateTime.now();
    loadImageData();
  }

  Future<void> loadImageData() async {
    final userData = ref.read(userProvider);
    String imageUrl = await getProperty('users', userData['id']!, 'image_url');
    ref.read(userProvider.notifier).setImageURL(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFF00541A),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 20),
              header(context),
              const SizedBox(height: 20),
              image(),
              const SizedBox(height: 20),
              details(context),
            ],
          ),
        ],
      ),
    );
  }

  Container details(BuildContext context) {
    var userData = ref.watch(userProvider);
    return Container(
      color: Colors.white,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Your Email',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            userData['email']!,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Password',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '•••••••••••••••••',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Phone Number',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            userData['phone']!,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          // Menampilkan tanggal terakhir diedit
          const Text(
            'Terakhir Diedit:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Tampilkan Date Picker
              showDatePicker(
                context: context,
                initialDate: _lastEditedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              ).then((pickedDate) {
                if (pickedDate != null) {
                  // Update nilai _lastEditedDate dengan tanggal yang dipilih
                  setState(() {
                    _lastEditedDate = pickedDate;
                  });
                }
              });
            },
            child: const Text('Pilih Tanggal'),
          ),
          const SizedBox(height: 10),
          // Menampilkan tanggal terakhir diedit
          Text(
            '$_lastEditedDate',
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  SizedBox image() {
    var userData = ref.watch(userProvider);
    return SizedBox(
      width: 300,
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
                  child: (userData['image_url'] != null &&
                          userData['image_url']!.isNotEmpty)
                      ? networkImage(userData['image_url']!, 300, 300)
                      : CircleAvatar(
                          radius: 150,
                          backgroundColor: Colors.grey,
                          child: Text(
                            userData['name']!.substring(0, 1),
                            style: const TextStyle(
                                fontSize: 80, color: Colors.white),
                          ),
                        )),
            ),
          ),
        ],
      ),
    );
  }

  Widget header(BuildContext context) {
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
            'Profil Pengguna',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                ),
          ),
          const Spacer(),
          Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () async {
                logOut(context);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.logout),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Tambahkan tombol "Edit Profil"
          Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _navigateToEditProfilePage, // Panggil fungsi navigasi
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.edit),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfilePage() {
    // Navigasi ke halaman EditProfilePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }
}
