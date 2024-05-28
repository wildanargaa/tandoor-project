import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uispeed_grocery_shop/providers/user_provider.dart';
import 'package:uispeed_grocery_shop/service/firebase_service.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState {
  // ignore: unused_field
  late TextEditingController _emailController;
  // ignore: unused_field
  late TextEditingController _passwordController;
  // ignore: unused_field
  late TextEditingController _phoneNumberController;
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  final String _imageURL = '';
  void _save() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    final userData = ref.watch(userProvider);
    ref.watch(userProvider.notifier).setUser(
        id: userData['id']!,
        name: _name,
        email: userData['email']!,
        phone: _phone,
        image_url: _imageURL);
    try {
      print(userData['id']);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userData['id'])
          .update({'name': _name, 'phone': _phone});
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00541A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image(),
              const SizedBox(height: 20),
              const Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: userData['email'],
                readOnly: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim() == '') {
                    return 'harus diisi';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _name = newValue!;
                },
                initialValue: userData['name'],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
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
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim() == '') {
                    return 'harus diisi';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _phone = newValue!;
                },
                initialValue: userData['phone'],
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox image() {
    var userData = ref.watch(userProvider);
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Stack(
        children: [
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
          Center(
              child: GestureDetector(
            onTap: () async {
              User? loggedInUser = await AuthService().getCurrentUser();
              if (loggedInUser != null) {
                await uploadImage('users', loggedInUser.uid, 'image_url');
                String imageUrl =
                    await getProperty('users', loggedInUser.uid, 'image_url');
                ref.read(userProvider.notifier).setImageURL(imageUrl);
              }
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(250),
                child: CircleAvatar(
                    radius: 150,
                    backgroundColor: Colors.black12.withOpacity(0.5),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 60,
                        ),
                        Text(
                          'Ubah profil',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ))),
          ))
        ],
      ),
    );
  }
}
