import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uispeed_grocery_shop/page/editprofile_page.dart';
import 'package:uispeed_grocery_shop/providers/user_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF00541A),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(height: 20),
              header(context),
              SizedBox(height: 20),
              image(),
              SizedBox(height: 20),
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
          SizedBox(height: 20),
          Text(
            'Your Email',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
          Text(
            userData['email']!,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Password',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '•••••••••••••••••',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Phone Number',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
          Text(
            userData['phone']!,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 20),
          // Menampilkan tanggal terakhir diedit
          Text(
            'Terakhir Diedit:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 10),
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
            child: Text('Pilih Tanggal'),
          ),
          SizedBox(height: 10),
          // Menampilkan tanggal terakhir diedit
          Text(
            '$_lastEditedDate',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
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
              decoration: BoxDecoration(
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
                    offset: Offset(0, 10),
                  ),
                ],
                borderRadius: BorderRadius.circular(250),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(250),
                child: Image.asset(
                  'asset/kubis.jpg',
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
          Spacer(),
          Text(
            'Profil Pengguna',
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  color: Colors.white,
                ),
          ),
          Spacer(),
          Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () async {
                FirebaseAuth.instance.signOut();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: Icon(Icons.logout),
              ),
            ),
          ),
          SizedBox(width: 10),
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
                child: Icon(Icons.edit),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfilePage() {
    // Navigasi ke halaman EditProfilePage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );
  }
}
