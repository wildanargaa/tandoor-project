import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uispeed_grocery_shop/providers/user_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
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
        phone: _phone);
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
        title: Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF00541A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: userData['email'],
                readOnly: true,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
