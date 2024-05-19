import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uispeed_grocery_shop/page/home_page.dart';
import 'package:uispeed_grocery_shop/providers/user_provider.dart';
import 'LoginScreen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final userCredential = snapshot.data;
            FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential!.uid)
                .get()
                .then(
                  (userData) => ref.watch(userProvider.notifier).setUser(
                        id: userCredential.uid,
                        name: userData.data()!['name'],
                        email: userData.data()!['email'],
                        phone: userData.data()!['phone'],
                      ),
                );

            return const HomePage();
          } else {
            return Scaffold(
              body: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xff00541A),
                ),
                child: Column(children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 180.0),
                    child: Image(
                      image: AssetImage('asset/WS_LogoTandoor.jpg'),
                      width: 210,
                      height: 75,
                    ),
                  ),
                  const SizedBox(
                    height: 120,
                  ),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    child: Container(
                      height: 48,
                      width: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white),
                      ),
                      child: const Center(
                        child: Text(
                          'SIGN IN',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  //  const SizedBox(height: 260,),
                  //  const Text('Login with Social Media',style: TextStyle(
                  //      fontSize: 17,
                  //      color: Colors.white
                  //  ),),//
                  // const SizedBox(height: 4,),
                  //  const Image(image: AssetImage('assets/social.png'))
                ]),
              ),
            );
          }
        }));
  }
}
